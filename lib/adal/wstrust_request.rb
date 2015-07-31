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

require_relative './logging'
require_relative './util'
require_relative './wstrust_response'
require_relative './xml_namespaces'

require 'erb'
require 'openssl'
require 'securerandom'
require 'time'

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
