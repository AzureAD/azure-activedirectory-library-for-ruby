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
  # Identifier for users for flows that don't require users to explicity log in.
  class UserIdentifier
    # All supported user identifier types. Any developer wishing to instantiate
    # this class can use this module as a mix-in or refer to the symbols
    # directly.
    module Type
      OPTIONAL_DISPLAYABLE_ID = :optional_displayable_id
      REQUIRED_DISPLAYABLE_ID = :required_displayable_id
      UNIQUE_ID = :unique_id
    end
    attr_reader :id
    attr_reader :type

    USER_IDENTIFIER_TYPES = [Type::OPTIONAL_DISPLAYABLE_ID,
                             Type::REQUIRED_DISPLAYABLE_ID,
                             Type::UNIQUE_ID]

    ##
    # Constructs a new UserIdentifier.
    #
    # @param String id
    #   The raw user identifier.
    # @param UserIdentifierType
    #   The type from the mix-in module UserIdentifier::Type.
    def initialize(id, type)
      unless USER_IDENTIFIER_TYPES.include? type
        fail ArgumentError, 'Unrecognized user identifier type'
      end

      @id = id
      @type = type
    end

    # The relevant OAuth parameters.
    def request_params
      fail NotImplementedError
    end
  end
end
