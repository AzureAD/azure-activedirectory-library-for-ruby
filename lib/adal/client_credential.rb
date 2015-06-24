require_relative './request_parameters'
require_relative './util'

module ADAL
  # A wrapper object for a client id and secret.
  class ClientCredential
    include RequestParameters
    include Util

    attr_reader :client_id
    attr_reader :client_secret

    def initialize(client_id, client_secret = nil)
      fail_if_arguments_nil(client_id)
      @client_id = client_id
      @client_secret = client_secret
    end

    # The relavent parameters from this credential for OAuth.
    def request_params
      { CLIENT_ID => @client_id, CLIENT_SECRET => @client_secret }
    end
  end
end
