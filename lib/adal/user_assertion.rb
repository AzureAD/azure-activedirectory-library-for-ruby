#-------------------------------------------------------------------------------
# # Copyright (c) Microsoft Open Technologies, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
# ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
# PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
#
# See the Apache License, Version 2.0 for the specific language
# governing permissions and limitations under the License.
#-------------------------------------------------------------------------------

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

    ##
    # The relevant OAuth access token request parameters for this object.
    #
    # @return Hash
    def request_params
      fail NotImplementedError
    end
  end
end
