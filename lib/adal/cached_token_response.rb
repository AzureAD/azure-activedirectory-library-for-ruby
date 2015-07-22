module ADAL
  # Proxy object for a token response with metadata.
  class CachedTokenResponse
    attr_reader :authority
    attr_reader :client
    attr_reader :client_id
    attr_reader :token_response

    ##
    # Constructs a new CachedTokenResponse.
    #
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   The credentials of the calling client application.
    # @param Authority authority
    #   The ADAL::Authority object that the response was retrieved from.
    # @param SuccessResponse token_response
    #   The token response to be cached.
    def initialize(client, authority, token_response)
      unless token_response.instance_of? SuccessResponse
        fail ArgumentError, 'Only SuccessResponses can be cached.'
      end
      @authority = authority
      @client = client
      @client_id = client.client_id
      @token_response = token_response
    end

    ##
    # Determines if self can be used to refresh other.
    # 
    # @param CachedTokenResponse other
    # @return Boolean
    def can_refresh?(other)
      mrrt? && (authority == other.authority) && (user_id == other.user_id)
    end

    ##
    # If the access token is within the expiration buffer of expiring, an
    # attempt will be made to retrieve a new token with the refresh token.
    #
    # @param Fixnum expiration_buffer_sec
    #   The number of seconds to use as leeway in determining if the token is
    #   expired. A positive buffer will refresh the token early while a negative
    #   buffer will refresh it late. Used to counter clock skew and network
    #   latency.
    # @return Boolean
    #   True if the token is still valid (even if it was refreshed). False if
    #   the token is expired an unable to be refreshed.
    def validate(expiration_buffer_sec = 0)
      return true if (Time.now + expiration_buffer_sec).to_i < expires_on
      unless refresh_token
        logger.verbose('Cached token is almost expired but no refresh token ' \
                       'is available.')
        return false
      end
      logger.verbose('Cached token is almost expired, attempting to refresh ' \
                     ' with refresh token.')
      refresh_response = refresh
      if refresh_response.instance_of? SuccessResponse
        logger.verbose('Successfully refreshed token in cache.')
        @token_response = refresh_response
        true
      else
        logger.warn('Failed to refresh token in cache with refresh token.')
        false
      end
    end

    ##
    # Attempts to refresh the access token for a given resource. Note that you
    # can call this method with a different resource even if the token is not
    # an MRRT, but it will fail
    #
    # @param String resource
    #   The resource that the new access token is beign requested for. Defaults
    #   to using the same resource as the original token.
    # @return TokenResponse
    def refresh(new_resource = resource)
      token_response = TokenRequest.new(authority, client)
        .get_with_refresh_token(refresh_token, new_resource)
      if token_response.instance_of? SuccessResponse
        token_response.parse_id_token(id_token)
      end
      token_response
    end

    ##
    # Changes the refresh token of the underlying token response.
    #
    # @param String token
    def refresh_token=(token)
      token_response.instance_variable_set(:@refresh_token, token)
      logger.verbose("Updated the refresh token for #{token_response}.")
    end

    ##
    # Is the token a Multi Resource Refresh Token?
    #
    # @return Boolean
    def mrrt?
      token_response.refresh_token && !!token_response.resource
    end

    ## Since the token cache may be implemented by the user of this library,
    ## all means of checking equality must be consistent.

    def ==(other)
      [:authority, :client_id, :token_response].all? do |field|
        (other.respond_to? field) && (send(field) == other.send(field))
      end
    end

    def eql?(other)
      self == other
    end

    def hash
      [authority, client_id, token_response].hash
    end

    private

    # CachedTokenResponse is just a proxy for TokenResponse.
    def method_missing(method, *args, &block)
      if token_response.respond_to?(method)
        token_response.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to_missing?(method, include_private = false)
      token_response.respond_to?(method, include_private) || super
    end
  end
end
