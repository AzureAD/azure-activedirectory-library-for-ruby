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

require 'erb'
require 'securerandom'

module ADAL
  # A request to a WS-Trust endpoint of an ADFS server. Used to obtain a SAML
  # token that can be exchanged for an access token at a token endpoint.
  class WSTrustRequest
    include Logging
    include Util
    include XmlNamespaces

    DEFAULT_APPLIES_TO = 'urn:federation:MicrosoftOnline'

    ACTION_TO_RST_TEMPLATE = {
      WSTRUST_13 =>
        File.expand_path('../templates/rst.13.xml.erb', __FILE__),
      WSTRUST_2005 =>
        File.expand_path('../templates/rst.2005.xml.erb', __FILE__)
    }

    ##
    # Constructs a new WSTrustRequest.
    #
    # @param String|URI endpoint
    # @param String action
    # @param String applies_to
    def initialize(
      endpoint, action = WSTRUST_13, applies_to = DEFAULT_APPLIES_TO)
      @applies_to = applies_to
      @endpoint = URI.parse(endpoint.to_s)
      @action = action
      @render = ERB.new(File.read(ACTION_TO_RST_TEMPLATE[action]))
    end

    ##
    # Performs a WS-Trust RequestSecurityToken request with a username and
    # password to obtain a federated token.
    #
    # @param String username
    # @param String password
    # @return WSTrustResponse
    def execute(username, password)
      logger.verbose("Making a WSTrust request with action #{@action}.")
      request = Net::HTTP::Get.new(@endpoint.path)
      add_headers(request)
      request.body = rst(username, password)
      response = http(@endpoint).request(request)
      if response.code == '200'
        WSTrustResponse.parse(response.body)
      else
        fail WSTrustResponse::WSTrustError, "Failed request: code #{response.code}."
      end
    end

    private

    # @param Net::HTTP::Get request
    def add_headers(request)
      request.add_field('Content-Type', 'application/soap+xml; charset=utf-8')
      request.add_field('SOAPAction', @action)
    end

    # @param String username
    # @param String password
    # @param String message_id
    # @return String
    def rst(username, password, message_id = SecureRandom.uuid)
      created = Time.now
      expires = created + 10 * 60   # 10 minute expiration
      @render.result(binding)
    end
  end
end
