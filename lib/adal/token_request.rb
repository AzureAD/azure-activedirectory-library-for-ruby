require_relative './noop_cache'
require_relative './oauth_request'
require_relative './request_parameters'

module ADAL
  # A request for a token that may be fulfilled by a cache or an OAuthRequest
  # to a token endpoint.
  class TokenRequest
    include RequestParameters

    module GrantTypes
      AUTHORIZATION_CODE = 'authorization_code'
      CLIENT_CREDENTIALS = 'client_credentials'
      REFRESH_TOKEN = 'refresh_token'
    end

    ##
    # Constructs a TokenRequest.
    #
    # @param [Authority] authority
    #   The Authority object containing the token and authorization endpoints.
    # @param [String] client_id
    #   The client id of the calling application.
    # @param [String] resource
    #   The resource that is being requested.
    # @option opt [TokenCache] :token_cache
    #   A cache that may be able to fulfill the request. If not provided,
    #   a no-op cache that contains no tokens will be used.
    # @option opt [String] :redirect_uri
    #   The redirect uri that was used to obtain the previous token or
    #   authorization code, if one was used.
    def initialize(authority, client_id, resource, opt = {})
      @authority = authority
      @client_id = client_id
      @resource = resource
      @token_cache = opt[:token_cache] || NoopCache.new
      @redirect_uri =
        URI.parse(opt[:redirect_uri].to_s) if opt.key? :redirect_uri
    end

    public

    # @return [TokenResponse]
    def get_with_authorization_code(authorization_code, client_secret)
      get(CLIENT_SECRET => client_secret,
          CODE => authorization_code,
          GRANT_TYPE => GrantTypes::AUTHORIZATION_CODE)
    end

    # @return [TokenResponse]
    def get_with_client_credentials(client_secret)
      get(CLIENT_SECRET => client_secret,
          GRANT_TYPE => GrantTypes::CLIENT_CREDENTIALS)
    end

    # @return [TokenResponse]
    def get_with_refresh_token(refresh_token, client_secret)
      get(CLIENT_SECRET => client_secret,
          GRANT_TYPE => GrantTypes::REFRESH_TOKEN,
          REFRESH_TOKEN => refresh_token)
    end

    private

    ##
    # Applies the request, first by checking the cache and then with OAuth.
    #
    # @return TokenResponse
    def get(opt)
      check_cache || oauth_request(request_params.merge(opt)).get
    end

    def request_params
      { CLIENT_ID => @client_id,
        REDIRECT_URI => @redirect_uri,
        RESOURCE => @resource }
    end

    ##
    # Attempts to fulfill the request from from @token_cache.
    #
    # @return TokenResponse
    #   If the cache contains a valid response it wil be returned as a
    #   SuccessResponse. Otherwise returns nil.
    def check_cache
      return unless @token_cache.find(self)
      fail NotImplementedError
    end

    ##
    # Constructs an OAuthRequest from the TokenRequest instance.
    #
    # @return OAuthRequest
    def oauth_request(params)
      OAuthRequest.new(@authority.token_endpoint, params)
    end
  end
end
