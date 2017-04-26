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

module ADAL
  # A client credential that consists of the client id and a JWT bearer
  # assertion. The type is 'urn:ietf:params:oauth:token-type:jwt'.
  class ClientAssertion
    include TokenRequest::GrantType
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

    ##
    # The relavent parameters from this credential for OAuth.
    #
    # @return Hash
    def request_params
      { CLIENT_ID => @client_id,
        CLIENT_ASSERTION_TYPE => @assertion_type,
        CLIENT_ASSERTION => @assertion }
    end
  end
end
