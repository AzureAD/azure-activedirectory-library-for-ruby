require_relative './logging'

require 'json'
require 'jwt'

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
    def self.from_raw(raw_response)
      logger.verbose('Attempting to create a TokenResponse from raw response.')
      if raw_response['error']
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

  # A token response that contains an access token.
  class SuccessResponse < TokenResponse
    include Logging

    attr_reader :access_token
    attr_reader :expires_in
    attr_reader :expires_on
    attr_reader :refresh_token
    attr_reader :scope
    attr_reader :token_type

    def initialize(opt)
      @access_token = opt['access_token']
      @expires_in = opt['expires_in'].to_i
      @expires_on = @expires_in + Time.now.to_i
      @refresh_token = opt['refresh_token']
      @scope = opt['scope']
      @token_type = opt['token_type']
      logger.info('Parsed a SuccessResponse with access token digest ' \
                  "#{Digest::SHA256.hexdigest @access_token.to_s} and " \
                  'refresh token digest ' \
                  "#{Digest::SHA256.hexdigest @refresh_token.to_s}.")
    end
  end

  # A token response that contains an error code.
  class ErrorResponse < TokenResponse
    include Logging

    attr_reader :error
    attr_reader :error_description
    attr_reader :error_codes
    attr_reader :timestamp
    attr_reader :trace_id
    attr_reader :correlation_id
    attr_reader :submit_url
    attr_reader :context

    def initialize(opt)
      @error = opt['error']
      @error_description = opt['error_description']
      @error_codes = opt['error_codes']
      @timestamp = opt['timestamp']
      @trace_id = opt['trace_id']
      @correlation_id = opt['correlation_id']
      @submit_url = opt['submit_url']
      @context = opt['context']
      logger.error("Parsed an ErrorResponse with error: #{@error} and error " \
                   "description: #{@error_description}.")
    end
  end
end
