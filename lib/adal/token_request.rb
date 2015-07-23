#-------------------------------------------------------------------------------
# # Copyright (c) Microsoft Open Technologies, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
# ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
# PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
#
# See the Apache License, Version 2.0 for the specific language
# governing permissions and limitations under the License.
#-------------------------------------------------------------------------------

require_relative './cache_driver'
require_relative './logging'
require_relative './noop_cache'
require_relative './oauth_request'
require_relative './request_parameters'

require 'openssl'

module ADAL
  # A request for a token that may be fulfilled by a cache or an OAuthRequest
  # to a token endpoint.
  class TokenRequest
    include Logging
    include RequestParameters

    # All accepted grant types. This module can be mixed-in to other classes
    # that require them.
    module GrantType
      AUTHORIZATION_CODE = 'authorization_code'
      CLIENT_CREDENTIALS = 'client_credentials'
      JWT_BEARER = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
      PASSWORD = 'password'
      REFRESH_TOKEN = 'refresh_token'
      SAML1 = 'urn:ietf:params:oauth:grant-type:saml1_1-bearer'
      SAML2 = 'urn:ietf:params:oauth:grant-type:saml2-bearer'
    end

    ##
    # Constructs a TokenRequest.
    #
    # @param [Authority] authority
    #   The Authority providing authorization and token endpoints.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   Used to identify the client. Provides a request_parameters method
    #   that yields the relevant client credential parameters.
    # @option [TokenCache] token_cache
    #   The cache implementation to store tokens. A NoopCache that stores no
    #   tokens will be used by default.
    def initialize(authority, client, token_cache = NoopCache.new)
      @authority = authority
      @cache_driver = CacheDriver.new(authority, client, token_cache)
      @client = client
      @token_cache = token_cache
    end

    public

    ##
    # Gets a token based solely on the clients credentials that were used to
    # initialize the token request.
    #
    # @param String resource
    #   The resource for which the requested access token will provide access.
    # @return TokenResponse
    def get_for_client(resource)
      logger.verbose("TokenRequest getting token for client for #{resource}.")
      request(GRANT_TYPE => GrantType::CLIENT_CREDENTIALS,
              RESOURCE => resource)
    end

    ##
    # Gets a token based on a previously acquired authentication code.
    #
    # @param String auth_code
    #   An authentication code that was previously acquired from an
    #   authentication endpoint.
    # @param String redirect_uri
    #   The redirect uri that was passed to the authentication endpoint when the
    #   auth code was acquired.
    # @optional String resource
    #   The resource for which the requested access token will provide access.
    # @return TokenResponse
    def get_with_authorization_code(auth_code, redirect_uri, resource = nil)
      logger.verbose('TokenRequest getting token with authorization code ' \
                     "#{auth_code}, redirect_uri #{redirect_uri} and " \
                     "resource #{resource}.")
      request(CODE => auth_code,
              GRANT_TYPE => GrantType::AUTHORIZATION_CODE,
              REDIRECT_URI => URI.parse(redirect_uri.to_s),
              RESOURCE => resource)
    end

    ##
    # Gets a token based on a previously acquired refresh token.
    #
    # @param String refresh_token
    #   The refresh token that was previously acquired from a token response.
    # @optional String resource
    #   The resource for which the requested access token will provide access.
    # @return TokenResponse
    def get_with_refresh_token(refresh_token, resource = nil)
      logger.verbose('TokenRequest getting token with refresh token digest ' \
                     "#{Digest::SHA256.hexdigest refresh_token} and resource " \
                     "#{resource}.")
      request_no_cache(GRANT_TYPE => GrantType::REFRESH_TOKEN,
                       REFRESH_TOKEN => refresh_token,
                       RESOURCE => resource)
    end

    ##
    # Gets a token based on possessing the users credentials.
    #
    # @param UserCredential user_cred
    #   Something that can be used to verify the user. Typically a username
    #   and password.
    # @optional String resource
    #   The resource for which the requested access token will provide access.
    # @return TokenResponse
    def get_with_user_credential(user_cred, resource = nil)
      logger.verbose('TokenRequest getting token with user credential ' \
                     "#{user_cred} and resource #{resource}.")
      request(user_cred.request_params.merge(RESOURCE => resource))
    end

    private

    ##
    # The OAuth parameters that are specific to the client for which tokens will
    # be requested.
    #
    # @return Hash
    def client_params
      @client.request_params
    end

    ##
    # Attempts to fulfill a token request, first via the token cache and then
    # through OAuth.
    #
    # @param Hash params
    #   Any additional request parameters that should be used.
    # @return TokenResponse
    def request(params)
      cached_token = check_cache(request_params(params))
      return cached_token if cached_token
      cache_response(request_no_cache(request_params(params)))
    end

    ##
    # Executes an OAuth request based on the params and returns it.
    #
    # @param Hash params
    #   Any additional request parameters that should be used.
    # @return TokenResponse
    def request_no_cache(params)
      oauth_request(request_params(params)).execute
    end

    ##
    # Adds client params to additional params. If there is a conflict, the value
    # from additional_params is used. It can be called multiple times, because
    # request_params(request_params(x)) == request_params(x).
    #
    # @param Hash
    # @return Hash
    def request_params(additional_params)
      client_params.merge(additional_params).select { |_, v| !v.nil? }
    end

    ##
    # Helper method to chain OAuthRequest and cache operation.
    #
    # @param TokenResponse
    #   The token response to cache.
    # @return TokenResponse
    def cache_response(token_response)
      @cache_driver.add(token_response)
      token_response
    end

    ##
    # Attempts to fulfill the request from @token_cache.
    #
    # @return TokenResponse
    #   If the cache contains a valid response it wil be returned as a
    #   SuccessResponse. Otherwise returns nil.
    def check_cache(params)
      logger.verbose("TokenRequest checking cache #{@token_cache} for token.")
      result = @cache_driver.find(params)
      logger.info("#{result ? 'Found' : 'Did not find'} token in cache.")
      result
    end

    ##
    # Constructs an OAuthRequest from the TokenRequest instance.
    #
    # @param Hash params
    #   The OAuth parameters specific to the TokenRequest instance.
    # @return OAuthRequest
    def oauth_request(params)
      logger.verbose('Resorting to OAuth to fulfill token request.')
      OAuthRequest.new(@authority.token_endpoint, params)
    end
  end
end
