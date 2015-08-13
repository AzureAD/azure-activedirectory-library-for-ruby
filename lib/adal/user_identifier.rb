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

module ADAL
  # Identifier for users in the cache.
  #
  # Ideally, the application will first use a different OAuth flow, such as the
  # Authorization Code flow, to acquire an ADAL::SuccessResponse. Then, it can
  # create ADAL::UserIdentifier to query the cache which will refresh tokens as
  # necessary.
  class UserIdentifier
    attr_reader :id
    attr_reader :type

    module Type
      UNIQUE_ID = :UNIQUE_ID
      DISPLAYABLE_ID = :DISPLAYABLE_ID
    end
    include Type

    ##
    # Creates a UserIdentifier with a specific type. Used for cache lookups.
    # Matches .NET ADAL implementation.
    #
    # @param String id
    # @param UserIdentifier::Type
    # @return ADAL::UserIdentifier
    def initialize(id, type)
      unless [UNIQUE_ID, DISPLAYABLE_ID].include? type
        fail ArgumentError, 'type must be an ADAL::UserIdentifier::Type.'
      end
      @id = id
      @type = type
    end

    ##
    # These parameters should only be used for cache lookup. This is enforced
    # by ADAL::TokenRequest.
    #
    # @return Hash
    def request_params
      { user_info: self }
    end

    ##
    # Overrides comparison operator for cache lookups
    #
    # @param UserIdentifier other
    # @return Boolean
    def ==(other)
      case other
      when UserIdentifier
        self.equal? other
      when UserInformation
        (type == UNIQUE_ID && id == other.unique_id) ||
          (type == DISPLAYABLE_ID && id == other.displayable_id)
      when String
        @id == other
      end
    end
  end
end
