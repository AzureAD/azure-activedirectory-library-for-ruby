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

    ACTION_XPATH = '//s:Envelope/s:Header/a:Action/text()'
    ERROR_XPATH = '//s:Envelope/s:Body/s:Fault/s:Code/s:Subcode/s:Value/text()'
    FAULT_XPATH = '//s:Envelope/s:Body/s:Fault/s:Reason'
    SECURITY_TOKEN_XPATH = './trust:RequestedSecurityToken'
    TOKEN_RESPONSE_XPATH =
      '//s:Envelope/s:Body/trust:RequestSecurityTokenResponse|//s:Envelope/s:' \
      'Body/trust:RequestSecurityTokenResponseCollection/trust:RequestSecurit' \
      'yTokenResponse'
    TOKEN_TYPE_XPATH = "./*[local-name() = 'TokenType']/text()"
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
      namespace = ACTION_TO_NAMESPACE[parse_action(xml)]
      token, token_type = parse_token(xml, namespace)
      if token && token_type
        WSTrustResponse.new(format_xml(token), format_xml(token_type))
      else
        fail WSTrustError, 'Unable to parse token from response.'
      end
    end

    ##
    # Determines whether the response uses WS-Trust 2005 or WS-Trust 1.3.
    #
    # @param Nokogiri::XML::Document xml
    # @return String
    def self.parse_action(xml)
      xml.xpath(ACTION_XPATH, NAMESPACES).to_s
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
    def self.format_xml(xml)
      xml.to_s.split("\n").map(&:strip).join
    end
    private_class_method :format_xml

    # @param Nokogiri::XML::Document
    # @return [Nokogiri::XML::Element, Nokogiri::XML::Text]
    def self.parse_token(xml, namespace)
      xml.xpath(TOKEN_RESPONSE_XPATH, namespace).select do |node|
        requested_token = node.xpath(SECURITY_TOKEN_XPATH, namespace)
        case requested_token.size
        when 0
          logger.warn('No security token in token response.')
          next
        when 1
          token = requested_token.xpath(TOKEN_XPATH, namespace).first
          next if token.nil?
          return token, parse_token_type(node)
        else
          fail WSTrustError, 'Found too many RequestedSecurityTokens.'
        end
      end
    end
    private_class_method :parse_token

    # @param Nokogiri::XML::Element token_response_node
    # @return Nokogiri::XML::Text
    def self.parse_token_type(token_response_node)
      type = token_response_node.xpath(TOKEN_TYPE_XPATH, NAMESPACES).first
      logger.warn('No type in token response node.') if type.nil?
      type
    end
    private_class_method :parse_token_type

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
