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

require 'nokogiri'
require 'uri'

module ADAL
  # Relevant fields from a Mex response.
  class MexResponse
    class MexError < StandardError; end

    POLICY_XPATH = '//definitions/Policy[./ExactlyOne/All/' \
                   'SignedEncryptedSupportingTokens/Policy/UsernameToken/' \
                   'Policy/WssUsernameToken10]'
    POLICY_ID_XPATH = '//definitions/Policy[./ExactlyOne/All/' \
                      'SignedEncryptedSupportingTokens/Policy/UsernameToken/' \
                      'Policy/WssUsernameToken10]/@Id'
    BINDING_XPATH = '//definitions/binding[./PolicyReference]'
    PORT_XPATH = '//definitions/service/port'
    ADDRESS_XPATH = './address/@location'

    ##
    # Parses the XML string response from the Metadata Exchange endpoint into
    # a MexResponse object.
    #
    # @param String response
    #
    def self.parse(response)
      xml = Nokogiri::XML(response).remove_namespaces!
      policy_ids = xml.xpath(POLICY_ID_XPATH).map { |attr| "\##{attr.value}" }
      matching_bindings = xml.xpath(BINDING_XPATH).map do |node|
        if policy_ids.include? node.xpath('./PolicyReference/@URI').to_s
          node.xpath('./@name').to_s
        end
      end.compact
      endpoints = xml.xpath(PORT_XPATH).map do |node|
        binding = node.xpath('./@binding').to_s.split(':').last
        node.xpath(ADDRESS_XPATH).to_s if matching_bindings.include? binding
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
