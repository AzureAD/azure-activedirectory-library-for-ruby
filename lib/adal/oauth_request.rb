require_relative './logging'
require_relative './request_parameters'
require_relative './util'

require 'net/http'
require 'uri'

module ADAL
  # A request that can be made to an authentication or token server.
  class OAuthRequest
    include RequestParameters
    include Util

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
    def execute
      request = Net::HTTP::Post.new(@endpoint_uri.path)
      add_headers(request)
      request.body = URI.encode_www_form(params)
      TokenResponse.parse(http(@endpoint_uri).request(request).body)
    end

    private

    ##
    # Adds the necessary OAuth headers.
    #
    # @param Net::HTTPGenericRequest
    def add_headers(request)
      return if Logging.correlation_id.nil?
      request.add_field(CLIENT_REQUEST_ID, Logging.correlation_id)
      request.add_field(CLIENT_RETURN_CLIENT_REQUEST_ID, true)
    end

    def default_parameters
      { encoding: DEFAULT_ENCODING,
        AAD_API_VERSION => '1.0' }
    end
  end
end
