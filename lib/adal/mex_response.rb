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

require_relative './xml_namespaces'

require 'nokogiri'
require 'uri'

module ADAL
  # Relevant fields from a Mex response.
  class MexResponse
    include XmlNamespaces

    class MexError < StandardError; end

    POLICY_XPATH = '//wsdl:definitions/wsp:Policy[./wsp:ExactlyOne/wsp:All/' \
                   'sp:SignedEncryptedSupportingTokens/wsp:Policy/' \
                   'sp:UsernameToken/wsp:Policy/sp:WssUsernameToken10]'
    POLICY_ID_XPATH = POLICY_XPATH + '/@wsu:Id'
    BINDING_XPATH = '//wsdl:definitions/wsdl:binding[./wsp:PolicyReference]'
    PORT_XPATH = '//wsdl:definitions/wsdl:service/wsdl:port'
    ADDRESS_XPATH = './soap12:address/@location'

    ##
    # Parses the XML string response from the Metadata Exchange endpoint into
    # a MexResponse object.
    #
    # @param String response
    # @return MexResponse
    def self.parse(response)
      xml = Nokogiri::XML(response)
      policy_ids = xml.xpath(POLICY_ID_XPATH, NAMESPACES).map { |attr| "\##{attr.value}" }
      matching_bindings = xml.xpath(BINDING_XPATH, NAMESPACES).map do |node|
        if policy_ids.include? node.xpath('./wsp:PolicyReference/@URI', NAMESPACES).to_s
          node.xpath('./@name').to_s
        end
      end.compact
      endpoints = xml.xpath(PORT_XPATH, NAMESPACES).map do |node|
        binding = node.xpath('./@binding', NAMESPACES).to_s.split(':').last
        node.xpath(ADDRESS_XPATH, NAMESPACES).to_s if matching_bindings.include? binding
      end.compact
      if endpoints.empty?
        fail MexError, 'No valid WS-Trust endpoints found in Mex Response.'
      end
      MexResponse.new(endpoints.sample)
    end

    attr_reader :wstrust_url

    ##
    # Constructs a new MexResponse.
    #
    # @param String|URI wstrust_url
    def initialize(wstrust_url)
      @wstrust_url = URI.parse(wstrust_url.to_s)
      unless @wstrust_url.instance_of? URI::HTTPS
        fail ArgumentError, 'Mex is only done over HTTPS.'
      end
    end

    # :nocov:
    def to_s
      "MexResponse[wstrust_url = #{@wstrust_url}]"
    end
    # :nocov:
  end
end
