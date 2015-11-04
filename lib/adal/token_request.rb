#-------------------------------------------------------------------------------
# Copyright (c) 2015 Micorosft Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

require 'openssl'

module ADAL
  # A request for a token that may be fulfilled by a cache or an OAuthRequest
  # to a token endpoint.
  class TokenRequest
    include Logging
    include RequestParameters

    # An error that signifies an attempt to perform OAuth with a UserIdentifier.
    # UserIdentifiers can only be used to retrieve access tokens from the cache,
    # so if no matching cache token is found, this error is thrown.
    class UserCredentialError < StandardError; end

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
    # @param UserCredential|UserIdentifier user_cred
    #   Something that can be used to verify the user. Typically a username
    #   and password. If it is a UserIdentifier, only the cache will be checked.
    #   If a matching token is not there, it will fail.
    # @optional String resource
    #   The resource for which the requested access token will provide access.
    # @return TokenResponse
    def get_with_user_credential(user_cred, resource = nil)
      logger.verbose('TokenRequest getting token with user credential ' \
                     "#{user_cred} and resource #{resource}.")
      oauth = if user_cred.is_a? UserIdentifier
                lambda do
                  fail UserCredentialError,
                       'UserIdentifier can only be used once there is a ' \
                       'matching token in the cache.'
                end
              end || -> {}
      request(user_cred.request_params.merge(RESOURCE => resource), &oauth)
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
    def request(params, &block)
      cached_token = check_cache(request_params(params))
      return cached_token if cached_token
      cache_response(request_no_cache(request_params(params), &block))
    end

    ##
    # Executes an OAuth request based on the params and returns it.
    #
    # @param Hash params
    #   Any additional request parameters that should be used.
    # @return TokenResponse
    def request_no_cache(params)
      yield if block_given?
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
