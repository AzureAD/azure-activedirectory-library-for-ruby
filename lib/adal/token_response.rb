require 'json'
require 'jwt'

module ADAL
  # The return type of all of the instance methods that return tokens.
  class TokenResponse
    def self.from_raw(raw_response)
      if raw_response['error']
        ErrorResponse.new(JSON.parse(raw_response))
      else
        SuccessResponse.new(JSON.parse(raw_response))
      end
    end

    public

    def error?
      self.respond_to? :error
    end
  end

  # A token response that contains an access token.
  class SuccessResponse < TokenResponse
    attr_reader :access_token
    attr_reader :expires_in
    attr_reader :expires_on
    attr_reader :refresh_token
    attr_reader :scope
    attr_reader :token_type

    def initialize(opt)
      @access_token = opt['access_token']
      @expires_in = opt['expires_in']
      @expires_on = opt['expires_on']
      @refresh_token = opt['refresh_token']
      @scope = opt['scope']
      @token_type = opt['token_type']
    end
  end

  # A token response that contains an error code.
  class ErrorResponse < TokenResponse
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
    end
  end
end
