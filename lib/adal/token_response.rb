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

require 'digest'
require 'json'
require 'jwt'
require 'securerandom'

module ADAL
  # The return type of all of the instance methods that return tokens.
  class TokenResponse
    extend Logging

    ##
    # Constructs a TokenResponse from a raw hash. It will return either a
    # SuccessResponse or an ErrorResponse depending on the fields of the hash.
    #
    # @param Hash raw_response
    #   The body of the HTTP response expressed as a raw hash.
    # @return TokenResponse
    def self.parse(raw_response)
      logger.verbose('Attempting to create a TokenResponse from raw response.')
      if raw_response.nil?
        ErrorResponse.new
      elsif raw_response['error']
        ErrorResponse.new(JSON.parse(raw_response))
      else
        SuccessResponse.new(JSON.parse(raw_response))
      end
    end

    public

    ##
    # Shorthand for checking if a token response is successful or failed.
    #
    # @return Boolean
    def error?
      self.respond_to? :error
    end
  end

  # A token response that contains an access token. All fields are read only
  # and may be nil. Some fields are only populated in certain flows.
  class SuccessResponse < TokenResponse
    include Logging

    # These fields may or may not be included in the response from the token
    # endpoint.
    OAUTH_FIELDS = [:access_token, :expires_in, :expires_on, :id_token,
                    :not_before, :refresh_token, :resource, :scope, :token_type]
    OAUTH_FIELDS.each { |field| attr_reader field }
    attr_reader :user_info
    attr_reader :fields

    ##
    # Constructs a SuccessResponse from a collection of fields returned from a
    # token endpoint.
    #
    # @param Hash
    def initialize(fields = {})
      @fields = fields
      fields.each { |k, v| instance_variable_set("@#{k}", v) }
      parse_id_token(id_token)
      @expires_on = @expires_in.to_i + Time.now.to_i
      logger.info('Parsed a SuccessResponse with access token digest ' \
                  "#{Digest::SHA256.hexdigest @access_token.to_s} and " \
                  'refresh token digest ' \
                  "#{Digest::SHA256.hexdigest @refresh_token.to_s}.")
    end

    ##
    # Converts the fields that were used to create this token response into
    # a JSON string. This is helpful for storing then in a database.
    #
    # @param JSON::Ext::Generator::State
    #   We don't care about this, because the JSON representation of this
    #   object does not depend on the fields before it.
    # @return String
    def to_json(_ = nil)
      JSON.unparse(fields)
    end

    ##
    # Parses the raw id token into an ADAL::UserInformation.
    # If the id token is missing, an ADAL::UserInformation will still be
    # generated, it just won't contain any displayable information.
    #
    # @param String id_token
    #   The id token to parse
    #   Adds an id token to the token response if one is not present
    def parse_id_token(id_token)
      if id_token.nil?
        logger.warn('No id token found.')
        @user_info ||= ADAL::UserInformation.new(unique_id: SecureRandom.uuid)
        return
      end
      logger.verbose('Attempting to decode id token in token response.')
      claims = JWT.decode(id_token.to_s, nil, false).first
      @id_token = id_token
      @user_info = ADAL::UserInformation.new(claims)
    end
  end

  # A token response that contains an error code.
  class ErrorResponse < TokenResponse
    include Logging

    OAUTH_FIELDS = [:error, :error_description, :error_codes, :timestamp,
                    :trace_id, :correlation_id, :submit_url, :context]
    OAUTH_FIELDS.each { |field| attr_reader field }

    # Constructs a Error from a collection of fields returned from a
    # token endpoint.
    #
    # @param Hash
    def initialize(fields = {})
      fields.each { |k, v| instance_variable_set("@#{k}", v) }
      logger.error("Parsed an ErrorResponse with error: #{@error} and error " \
                   "description: #{@error_description}.")
    end
  end
end
