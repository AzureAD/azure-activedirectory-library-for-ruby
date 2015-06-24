require_relative './assertion.rb'

module ADAL
  # A client credential that consists of the client id and a JWT bearer
  # assertion. The type is 'urn:ietf:params:oauth:token-type:jwt'.
  class ClientAssertion
    include Assertion

    attr_reader :assertion
    attr_reader :assertion_type
    attr_reader :client_id

    ##
    # Creates a new ClientAssertion.
    #
    # @param [String] client_id
    #   The client id of the calling application.
    # @param [String] assertion
    #   The JWT used as a credential.
    def initialize(client_id, assertion)
      @assertion = assertion
      @assertion_type = JWT_BEARER
      @client_id = client_id
    end

    # The relavent parameters from this credential for OAuth.
    def request_params
      fail NotImplementedError
    end
  end
end
