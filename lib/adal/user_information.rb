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
  # Basically just a holder for the id token.
  class UserInformation
    ID_TOKEN_FIELDS = [:aud, :iss, :iat, :nbf, :exp, :ver, :tid, :oid, :upn,
                       :sub, :given_name, :family_name, :name, :amr,
                       :unique_name, :nonce, :email]
    ID_TOKEN_FIELDS.each { |field| attr_reader field }
    attr_reader :unique_id
    attr_reader :displayable_id

    ##
    # Constructs a new UserInformation.
    #
    # @param Hash claims
    #   Claims from an id token. The exact claims will vary, so whatever is not
    #   found in the claims will be nil.
    def initialize(claims)
      claims.each { |k, v| instance_variable_set("@#{k}", v) }
      @unique_id = oid || sub || unique_id
      @displayable_id = upn || email
    end

    def ==(other)
      unique_id == other.unique_id && displayable_id == other.displayable_id
    end
  end
end
