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

require 'nokogiri'
require 'uri'

module ADAL
  # Relevant fields from a Mex response.
  class MexResponse
    include XmlNamespaces

    class << self
      include Logging
    end

    class MexError < StandardError; end

    POLICY_ID_XPATH =
      '//wsdl:definitions/wsp:Policy[./wsp:ExactlyOne/wsp:All/sp:SignedSuppor' \
      'tingTokens/wsp:Policy/sp:UsernameToken/wsp:Policy/sp:WssUsernameToken1' \
      '0]/@u:Id|//wsdl:definitions/wsp:Policy[./wsp:ExactlyOne/wsp:All/ssp:Si' \
      'gnedEncryptedSupportingTokens/wsp:Policy/ssp:UsernameToken/wsp:Policy/' \
      'ssp:WssUsernameToken10]/@u:Id'
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
      policy_ids = parse_policy_ids(xml)
      bindings = parse_bindings(xml, policy_ids)
      endpoint, binding = parse_endpoint_and_binding(xml, bindings)
      MexResponse.new(endpoint, binding)
    end

    # @param Nokogiri::XML::Document xml
    # @param Array[String] policy_ids
    # @return Array[String]
    def self.parse_bindings(xml, policy_ids)
      matching_bindings = xml.xpath(BINDING_XPATH, NAMESPACES).map do |node|
        reference_uri = node.xpath('./wsp:PolicyReference/@URI', NAMESPACES)
        node.xpath('./@name').to_s if policy_ids.include? reference_uri.to_s
      end.compact
      fail MexError, 'No matching bindings found.' if matching_bindings.empty?
      matching_bindings
    end
    private_class_method :parse_bindings

    # @param Nokogiri::XML::Document xml
    # @param Array[String] bindings
    # @return Array[[String, String]]
    def self.parse_all_endpoints(xml, bindings)
      endpoints = xml.xpath(PORT_XPATH, NAMESPACES).map do |node|
        binding = node.attr('binding').split(':').last
        if bindings.include? binding
          [node.xpath(ADDRESS_XPATH, NAMESPACES).to_s, binding]
        end
      end.compact
      endpoints
    end
    private_class_method :parse_all_endpoints

    # @param Nokogiri::XML::Document xml
    # @param Array[String] bindings
    # @return [String, String]
    def self.parse_endpoint_and_binding(xml, bindings)
      endpoints = parse_all_endpoints(xml, bindings)
      case endpoints.size
      when 0
        fail MexError, 'No valid WS-Trust endpoints found.'
      when 1
      else
        logger.info('Multiple WS-Trust endpoints were found in the mex ' \
                    'response. Only one was used.')
      end
      prefer_13(endpoints).first
    end
    private_class_method :parse_endpoint_and_binding

    # @param Nokogiri::XML::Document xml
    # @return Array[String]
    def self.parse_policy_ids(xml)
      policy_ids = xml.xpath(POLICY_ID_XPATH, NAMESPACES)
                   .map { |attr| "\##{attr.value}" }
      fail MexError, 'No username token policy nodes.' if policy_ids.empty?
      policy_ids
    end
    private_class_method :parse_policy_ids

    # @param Array[String, String] endpoints
    # @return Array[String, String] endpoints
    def self.prefer_13(endpoints)
      only13 = endpoints.select { |_, b| BINDING_TO_ACTION[b] == WSTRUST_13 }
      only13.empty? ? endpoints : only13
    end
    private_class_method :prefer_13

    attr_reader :action
    attr_reader :wstrust_url

    ##
    # Constructs a new MexResponse.
    #
    # @param String|URI wstrust_url
    # @param String action
    def initialize(wstrust_url, binding)
      @action = BINDING_TO_ACTION[binding]
      @wstrust_url = URI.parse(wstrust_url.to_s)
      return if @wstrust_url.instance_of? URI::HTTPS
      fail ArgumentError, 'Mex is only done over HTTPS.'
    end
  end
end
