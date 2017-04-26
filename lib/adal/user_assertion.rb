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
  # An assertion and its representation type, stored as a JWT for
  # the on-behalf-of flow.
  class UserAssertion
    attr_reader :assertion
    attr_reader :assertion_type

    ##
    # Creates a new UserAssertion.
    #
    # @param String assertion
    #   An OAuth assertion representing the user.
    # @optional AssertionType assertion_type
    #   The type of the assertion being made. Currently only JWT_BEARER is
    #   supported.
    def initialize(
      assertion, assertion_type = ADAL::TokenRequest::GrantType::JWT_BEARER)
      @assertion = assertion
      @assertion_type = assertion_type
    end

    ##
    # The relevant OAuth access token request parameters for this object.
    #
    # @return Hash
    def request_params
      { grant_type: assertion_type,
        assertion: assertion,
        requested_token_use: :on_behalf_of,
        scope: :openid }
    end
  end
end
