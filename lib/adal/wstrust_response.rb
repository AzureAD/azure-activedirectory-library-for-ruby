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

require_relative './token_request'
require_relative './xml_namespaces'

require 'nokogiri'

module ADAL
  # Relevant fields from a WS-Trust response.
  class WSTrustResponse
    include XmlNamespaces

    # All recognized SAML token types.
    module TokenType
      V1 = 'urn:oasis:names:tc:SAML:1.0:assertion'
      V2 = 'urn:oasis:names:tc:SAML:2.0:assertion'

      ALL_TYPES = [V1, V2]
    end

    class WSTrustError < StandardError; end
    class WSTrustResponseError < WSTrustError; end
    class UnrecognizedTokenTypeError < WSTrustError; end

    TOKEN_RESPONSE_XPATH = '//s:Envelope/s:Body/trust:RequestSecurityTokenRes' \
                           'ponseCollection/trust:RequestSecurityTokenResponse'
    TOKEN_XPATH = "./trust:RequestedSecurityToken/*[local-name() = 'Assertion']"
    TOKEN_TYPE_XPATH = './trust:TokenType/text()'
    FAULT_XPATH = '//s:Envelope/s:Body/s:Fault/s:Reason'
    ERROR_XPATH = '//s:Envelope/s:Body/s:Fault/s:Code/s:Subcode/s:Value/text()'

    ##
    # Parses a WS-Trust response from raw XML into an ADAL::WSTrustResponse
    # object. Throws an error if the response contains an error.
    #
    # @param String|Nokogiri::XML raw_xml
    # @return ADAL::WSTrustResponse
    def self.parse(raw_xml)
      parse_error(raw_xml)
      xml = Nokogiri::XML(raw_xml.to_s)
      token_response = xml.xpath(TOKEN_RESPONSE_XPATH, NAMESPACES).first
      fail WSTrustResponseError, 'No valid token response.' unless token_response
      WSTrustResponse.new(
        format_xml(token_response.xpath(TOKEN_XPATH, NAMESPACES).first),
        token_response.xpath(TOKEN_TYPE_XPATH, NAMESPACES).first.to_s)
    end

    ##
    # Checks a WS-Trust response for properly formatted error codes and
    # descriptions. If found, raises an appropriate exception.
    #
    # @param String|Nokogiri::XML raw_xml
    def self.parse_error(raw_xml)
      xml = Nokogiri::XML(raw_xml.to_s)
      fault = xml.xpath(FAULT_XPATH, NAMESPACES).first
      error = xml.xpath(ERROR_XPATH, NAMESPACES).first
      error = format_xml(error).split(':')[1] || error if error
      if fault || error
        fail WSTrustResponseError, "Fault: #{fault}. Error: #{error}."
      end
    end

    # @param Nokogiri::XML::Document
    # @return String
    private_class_method def self.format_xml(nokogiri_doc)
      nokogiri_doc.to_s.split("\n").map(&:strip).join
    end

    attr_reader :token

    def initialize(token, token_type)
      unless TokenType::ALL_TYPES.include? token_type
        fail UnrecognizedTokenTypeError, token_type
      end
      @token = token
      @token_type = token_type
    end

    ##
    # Gets the OAuth grant type for the SAML token type of the response.
    #
    # @return TokenRequest::GrantType
    def grant_type
      case @token_type
      when TokenType::V1
        TokenRequest::GrantType::SAML1
      when TokenType::V2
        TokenRequest::GrantType::SAML2
      end
    end
  end
end
