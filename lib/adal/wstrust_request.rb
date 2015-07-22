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

require_relative './util'
require_relative './wstrust_response'

require 'erb'
require 'openssl'
require 'securerandom'
require 'time'

module ADAL
  # A request to a WS-Trust endpoint of an ADFS server. Used to obtain a SAML
  # token that can be exchanged for an access token at a token endpoint.
  class WSTrustRequest
    include Util

    DEFAULT_APPLIES_TO = 'urn:federation:MicrosoftOnline'
    RST_TEMPLATE_PATH = File.expand_path('../templates/rst.xml.erb', __FILE__)
    RST_TEMPLATE_RENDERER = ERB.new(File.read(RST_TEMPLATE_PATH))

    ##
    # Constructs a new WSTrustRequest.
    #
    # @param String|URI endpoint
    def initialize(endpoint, applies_to = DEFAULT_APPLIES_TO)
      @applies_to = applies_to
      @endpoint = URI.parse(endpoint.to_s)
    end

    ##
    # Performs a WS-Trust RequestSecurityToken request with a username and
    # password to obtain a federated token.
    #
    # @param String username
    # @param String password
    # @return WSTrustResponse
    def execute(username, password)
      request = Net::HTTP::Get.new(@endpoint.path)
      add_headers(request)
      request.body = rst(username, password)
      WSTrustResponse.parse(http(@endpoint).request(request).body)
    end

    private

    def add_headers(request)
      request.add_field('Content-Type', 'application/soap+xml; charset=utf-8')
      request.add_field('SOAPAction', 'http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue')
    end

    # @return String
    def rst(username, password, message_id = SecureRandom.uuid)
      created = Time.now
      expires = created + 10 * 60   # 10 minute expiration
      RST_TEMPLATE_RENDERER.result(binding)
    end
  end
end
