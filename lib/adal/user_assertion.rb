require_relative './assertion.rb'

module ADAL
  # An assertion and its representation type, stored as a JWT for
  # the on-behalf-of flow, as well as the user who the token was requested for.
  class UserAssertion
    include Assertion

    attr_reader :assertion
    attr_reader :assertion_type
    attr_reader :username

    ##
    # Creates a new UserAssertion.
    #
    # @param [String] assertion
    #   An OAuth assertion representing the user.
    # @param [AssertionType] assertion_type
    #   The type of the assertion being made. Currently only JWT_BEARER is
    #   supported.
    # @param [String] username
    #   The user that the token is requested on behalf of.
    def initialize(assertion, assertion_type = JWT_BEARER, username = nil)
      unless ALL_TYPES.include? assertion_type
        fail ArgumentError, 'Invalid assertion type.'
      end
      @assertion = assertion
      @assertion_type = assertion_type
      @username = username
    end
  end
end
