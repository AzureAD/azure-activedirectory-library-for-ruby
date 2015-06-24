require 'net/http'
require 'uri'

module ADAL
  # TODO(aj-michael) Document this so rubocop stops complaining.
  class AuthenticationParameters
    BEARER_CHALLENGE_VALIDATION = /^\s*Bearer\s+([^,\s="]+?)="?([^"]*?)"?\s*
      (,\s*([^,\s="]+?)="([^:]*?)"\s*)*$/x
    FIRST_KEY_VALUE = /^\s*Bearer\s+([^, \s="]+?)="([^"]*?)"\s*/
    OTHER_KEY_VALUE = /(?:,\s*([^,\s="]+?)="([^"]*?)"\s*)/
    WWW_AUTHENTICATE_HEADER = 'www-authenticate'

    attr_reader :authority_uri
    attr_reader :resource

    ##
    # Creates authentication parameters from the address of the resource. The
    # resource server must respond with 401 unauthorized response with a
    # www-authenticate header containing the authentication parameters.
    #
    # @param URI resource_url
    #   The address of the desired resource.
    # @return AuthenticationParameters
    def self.create_from_resource_url(resource_url)
      response = Net::HTTP.post_form(URI.parse(resource_url.to_s), {})
      if response.key? WWW_AUTHENTICATE_HEADER
        create_from_response_authenticate_header(
          response[WWW_AUTHENTICATE_HEADER])
      else
        fail ArgumentError, 'The specified resource uri does not support ' \
          'OAuth challenges.'
      end
    end

    def self.create_from_response_authenticate_header(challenge)
      params = parse_challenge(challenge)
      AuthenticationParameters.new(
        params['authorization_uri'], params['resource'])
    end

    ##
    # Parses a challenge from the www-authenticate header into a hash of
    # parameters.
    #
    # @param String challenge
    # @return Hash
    def self.parse_challenge(challenge)
      puts challenge
      puts challenge =~ BEARER_CHALLENGE_VALIDATION
      if challenge !~ BEARER_CHALLENGE_VALIDATION
        puts challenge
        fail ArgumentError, 'The challenge is not parseable as an RFC6750 ' \
          'OAuth2 challenge.'
      end
      Hash[challenge.scan(FIRST_KEY_VALUE) + challenge.scan(OTHER_KEY_VALUE)]
    end

    def initialize(authority_uri, resource)
      @authority_uri = authority_uri
      @resource = resource
    end
  end
end
