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
      request.body = URI.encode_www_form(string_hash(params))
      TokenResponse.parse(http(@endpoint_uri).request(request).body)
    end

    private

    ##
    # Adds the necessary OAuth headers.
    #
    # @param Net::HTTPGenericRequest
    def add_headers(request)
      return if Logging.correlation_id.nil?
      request.add_field(CLIENT_REQUEST_ID.to_s, Logging.correlation_id)
      request.add_field(CLIENT_RETURN_CLIENT_REQUEST_ID.to_s, true)
    end

    def default_parameters
      { encoding: DEFAULT_ENCODING,
        AAD_API_VERSION => '1.0' }
    end
  end
end
