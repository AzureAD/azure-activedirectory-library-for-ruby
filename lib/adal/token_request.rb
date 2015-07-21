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
      JWT_BEARER = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
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
      @client = client
      @token_cache = token_cache
    end

    public

    def client_params
      @client.request_params
    end

    # @param String resource
    # @return [TokenResponse]
    def get_for_client(resource)
      logger.verbose("TokenRequest getting token for client for #{resource}.")
      get_with_request_params(GRANT_TYPE => GrantType::CLIENT_CREDENTIALS,
                              RESOURCE => resource)
    end

    # @param String auth_code
    # @param String redirect_uri
    # @param String resource
    # @return [TokenResponse]
    def get_with_authorization_code(auth_code, redirect_uri, resource = nil)
      logger.verbose('TokenRequest getting token with authorization code ' \
                     "#{auth_code}, redirect_uri #{redirect_uri} and " \
                     "resource #{resource}.")
      get_with_request_params(CODE => auth_code,
                              GRANT_TYPE => GrantType::AUTHORIZATION_CODE,
                              REDIRECT_URI => URI.parse(redirect_uri.to_s),
                              RESOURCE => resource)
    end

    # @param String refresh_token
    # @param String resource
    # @return [TokenResponse]
    def get_with_refresh_token(refresh_token, resource = nil)
      logger.verbose('TokenRequest getting token with refresh token digest ' \
                     "#{Digest::SHA256.hexdigest refresh_token} and resource " \
                     "#{resource}.")
      get_with_request_params(GRANT_TYPE => GrantType::REFRESH_TOKEN,
                              REFRESH_TOKEN => refresh_token,
                              RESOURCE => resource)
    end

    # @param UserCredential user_cred
    # @param String resource
    # @return [TokenResponse]
    def get_with_user_credential(user_cred, resource = nil)
      logger.verbose('TokenRequest getting token with user credential ' \
                     "#{user_cred} and resource #{resource}.")
      get_with_request_params(
        user_cred.request_params.merge(RESOURCE => resource))
    end

    private

    ##
    # Applies the request, first by checking the cache and then with OAuth.
    #
    # @return TokenResponse
    def get_with_request_params(request_params)
      all_params = client_params.merge(request_params).select { |_, v| !v.nil? }
      check_cache || oauth_request(all_params).execute
    end

    ##
    # Attempts to fulfill the request from @token_cache.
    #
    # @return TokenResponse
    #   If the cache contains a valid response it wil be returned as a
    #   SuccessResponse. Otherwise returns nil.
    def check_cache
      logger.verbose("TokenRequest checking cache #{@token_cache} for token.")
      @token_cache.find(self)
    end

    ##
    # Constructs an OAuthRequest from the TokenRequest instance.
    #
    # @return OAuthRequest
    def oauth_request(params)
      logger.verbose('TokenRequest did not find the token in the cache.')
      OAuthRequest.new(@authority.token_endpoint, params)
    end
  end
end
