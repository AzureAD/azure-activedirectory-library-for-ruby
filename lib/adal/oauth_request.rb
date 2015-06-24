require_relative './request_parameters'

require 'net/http'
require 'uri'

module ADAL
  # A request that can be made to an authentication or token server.
  class OAuthRequest
    include RequestParameters

    DEFAULT_CONTENT_TYPE = 'application/x-www-form-urlencoded'
    DEFAULT_ENCODING = 'utf8'
    SSL_SCHEME = 'https'

    def initialize(endpoint, params)
      @endpoint_uri = URI.parse(endpoint.to_s)
      @params = params
    end

    def params
      default_parameters.merge(@params)
    end

    ##
    # Requests and waits for a token from the endpoint.
    # @return TokenResponse
    def get
      TokenResponse.from_raw(Net::HTTP.post_form(@endpoint_uri, @params).body)
    end

    private

    def default_parameters
      { encoding: DEFAULT_ENCODING,
        Parameters::AAD_API_VERSION => AAD_API_VERSION }
    end
  end
end
