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

require 'net/http'
require 'uri'

module ADAL
  # Authentication parameters from an unauthorized 401 response from a resource
  # server that can be used to create an AuthenticationContext.
  class AuthenticationParameters
    extend Logging
    include Util

    AUTHENTICATE_HEADER = 'www-authenticate'
    AUTHORITY_KEY = 'authorization_uri'
    RESOURCE_KEY = 'resource'

    BEARER_CHALLENGE_VALIDATION = /^\s*Bearer\s+([^,\s="]+?)="?([^"]*?)"?\s*
      (,\s*([^,\s="]+?)="([^:]*?)"\s*)*$/x
    private_constant :BEARER_CHALLENGE_VALIDATION
    FIRST_KEY_VALUE = /^\s*Bearer\s+([^, \s="]+?)="([^"]*?)"\s*/
    private_constant :FIRST_KEY_VALUE
    OTHER_KEY_VALUE = /(?:,\s*([^,\s="]+?)="([^"]*?)"\s*)/
    private_constant :OTHER_KEY_VALUE

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
      logger.verbose('Attempting to retrieve authentication parameters from ' \
                     "#{resource_url}.")
      response = Net::HTTP.post_form(URI.parse(resource_url.to_s), {})
      unless response.key? AUTHENTICATE_HEADER
        fail ArgumentError, 'The specified resource uri does not support ' \
          'OAuth challenges.'
      end
      create_from_authenticate_header(response[AUTHENTICATE_HEADER])
    end

    ##
    # Creates an AuthenticationParameters object from a www-authenticate
    # response header.
    #
    # @param String challenge
    #   The raw www-authenticate header.
    # @return AuthenticationParameters
    def self.create_from_authenticate_header(challenge)
      params = parse_challenge(challenge)
      if params.nil? || !params.key?(AUTHORITY_KEY)
        logger.warn('Unable to create AuthenticationParameters from header ' \
                    "#{challenge}.")
        return
      end
      logger.verbose("Authentication header #{challenge} was successfully " \
                     'parsed as an OAuth challenge into a parameters hash.')
      AuthenticationParameters.new(
        params[AUTHORITY_KEY], params[RESOURCE_KEY])
    end

    ##
    # Parses a challenge from the www-authenticate header into a hash of
    # parameters.
    #
    # @param String challenge
    # @return Hash
    def self.parse_challenge(challenge)
      if challenge !~ BEARER_CHALLENGE_VALIDATION
        logger.warn("#{challenge} is not parseable as an RFC6750 OAuth2 " \
                    'challenge.')
        return
      end
      Hash[challenge.scan(FIRST_KEY_VALUE) + challenge.scan(OTHER_KEY_VALUE)]
    end
    private_class_method :parse_challenge

    ##
    # Constructs a new AuthenticationParameters.
    #
    # @param String|URI authority_uri
    #   The uri of the authority server, including both host and tenant.
    # @param String
    def initialize(authority_uri, resource = nil)
      fail_if_arguments_nil(authority_uri)
      @authority_uri = URI.parse(authority_uri.to_s)
      @resource = resource
    end

    ##
    # Creates an AuthenticationContext based on the parameters.
    #
    # @return AuthenticationContext
    def create_context
      AuthenticationContext.new(@authority_uri.host, @authority_uri.path[1..-1])
    end
  end
end
