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
require_relative './token_request'
require_relative './util'
require_relative './xml_namespaces'

require 'nokogiri'

module ADAL
  # Relevant fields from a WS-Trust response.
  class WSTrustResponse
    include XmlNamespaces

    class << self
      include Logging
      include Util
    end

    # All recognized SAML token types.
    module TokenType
      V1 = 'urn:oasis:names:tc:SAML:1.0:assertion'
      V2 = 'urn:oasis:names:tc:SAML:2.0:assertion'

      ALL_TYPES = [V1, V2]
    end

    class WSTrustError < StandardError; end
    class UnrecognizedTokenTypeError < WSTrustError; end

    ERROR_XPATH = '//s:Envelope/s:Body/s:Fault/s:Code/s:Subcode/s:Value/text()'
    FAULT_XPATH = '//s:Envelope/s:Body/s:Fault/s:Reason'
    SECURITY_TOKEN_XPATH = './wst:RequestedSecurityToken'
    TOKEN_RESPONSE_XPATH = '//s:Envelope/s:Body/trust:RequestSecurityTokenRes' \
                           'ponseCollection/trust:RequestSecurityTokenResponse'
    TOKEN_TYPE_XPATH = './trust:TokenType/text()'
    TOKEN_XPATH = "./*[local-name() = 'Assertion']"

    ##
    # Parses a WS-Trust response from raw XML into an ADAL::WSTrustResponse
    # object. Throws an error if the response contains an error.
    #
    # @param String|Nokogiri::XML raw_xml
    # @return ADAL::WSTrustResponse
    def self.parse(raw_xml)
      fail_if_arguments_nil(raw_xml)
      xml = Nokogiri::XML(raw_xml.to_s)
      parse_error(xml)
      token, token_type = parse_token(xml)
      if token && token_type
        WSTrustResponse.new(format_xml(token), format_xml(token_type))
      else
        fail WSTrustError, 'Unable to parse token from response.'
      end
    end

    ##
    # Checks a WS-Trust response for properly formatted error codes and
    # descriptions. If found, raises an appropriate exception.
    #
    # @param Nokogiri::XML::Document xml
    def self.parse_error(xml)
      fault = xml.xpath(FAULT_XPATH, NAMESPACES).first
      error = xml.xpath(ERROR_XPATH, NAMESPACES).first
      error = format_xml(error).split(':')[1] || error if error
      fail WSTrustError, "Fault: #{fault}. Error: #{error}." if fault || error
    end

    # @param Nokogiri::XML::Document xml
    # @return String
    private_class_method def self.format_xml(xml)
      xml.to_s.split("\n").map(&:strip).join
    end

    # @param Nokogiri::XML::Document
    # @return [Nokogiri::XML::Element, Nokogiri::XML::Text]
    private_class_method def self.parse_token(xml)
      xml.xpath(TOKEN_RESPONSE_XPATH, NAMESPACES).select do |node|
        type = parse_token_type(node)
        requested_token = node.xpath(SECURITY_TOKEN_XPATH, NAMESPACES)
        case requested_token.size
        when 0
          logger.warn("No security token in token response of type #{type}.")
          next
        when 1
          token = requested_token.xpath(TOKEN_XPATH).first
          next if token.nil?
          return token, type
        else
          fail WSTrustError, 'Found too many RequestedSecurityTokens.'
        end
      end
    end

    # @param Nokogiri::XML::Element token_response_node
    # @return Nokogiri::XML::Text
    private_class_method def self.parse_token_type(token_response_node)
      type = token_response_node.xpath(TOKEN_TYPE_XPATH, NAMESPACES).first
      logger.warn('No type in token response node.') if type.nil?
      type
    end

    attr_reader :token

    ##
    # Constructs a WSTrustResponse.
    #
    # @param String token
    #   The content of the returned token.
    # @param WSTrustResponse::TokenType token_type
    #   The type of the token contained within the WS-Trust response.
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
