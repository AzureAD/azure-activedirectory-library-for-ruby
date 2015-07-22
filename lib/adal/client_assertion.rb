require_relative './assertion'
require_relative './request_parameters'
require_relative './util'

module ADAL
  # A client credential that consists of the client id and a JWT bearer
  # assertion. The type is 'urn:ietf:params:oauth:token-type:jwt'.
  class ClientAssertion
    include Assertion
    include RequestParameters
    include Util

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
    def initialize(client_id, assertion, assertion_type = JWT_BEARER)
      fail_if_arguments_nil(client_id, assertion, assertion_type)
      @assertion = assertion
      @assertion_type = assertion_type
      @client_id = client_id
    end

    # The relavent parameters from this credential for OAuth.
    def request_params
      { CLIENT_ID => @client_id,
        CLIENT_ASSERTION_TYPE => @assertion_type,
        CLIENT_ASSERTION => @assertion }
    end
  end
end
