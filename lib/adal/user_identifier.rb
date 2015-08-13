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
  # Identifier for users in the cache. Also useful for accessing the personal
  # info from an id token.
  #
  # Ideally, the application will first use a different OAuth flow, such as the
  # Authorization Code flow, to acquire an ADAL::SuccessResponse. Then, they can
  # extract the ADAL::UserIdentifier from the response as `response.user_id` and
  # user it for future calls for tokens, and the cache will handle refreshing
  # the access tokens when they expire.
  class UserIdentifier
    ID_TOKEN_FIELDS = [:aud, :iss, :iat, :nbf, :exp, :ver, :tid, :oid, :upn,
                       :sub, :given_name, :family_name, :name, :amr,
                       :unique_name, :nonce, :email]
    ID_TOKEN_FIELDS.each { |field| attr_reader field }
    attr_reader :user_id

    ##
    # Constructs an ADAL::UserIdentifier based from the string representation
    # of the user id. This allows for a simple means of saving ids in a data
    # store without the overhead of serialization
    #
    # @param String id
    # @return ADAL::UserIdentifier
    def self.from_user_id(id)
      ADAL::UserIdentifier.new(upn: id)
    end

    ##
    # Constructs a new UserIdentifier.
    #
    # @param Hash claims
    #   Claims from an id token. The exact claims will vary, so whatever is not
    #   found in the claims will be nil.
    def initialize(claims)
      claims.each { |k, v| instance_variable_set("@#{k}", v) }
      # This logic is consistent with the other ADAL libraries.
      @user_id = upn || email
      return (@displayable = true) if @user_id
      @user_id = sub || oid
      return (@displyable = false) if @user_id
      @user_id = unique_name
      return (@displayable = true) if @user_id
      @user_id = SecureRandom.uuid
      @displayable = false
    end

    ##
    # Whether or not the user_id field is reasonably human-readable.
    #
    # @return Boolean
    def displayable?
      @displayable
    end

    ##
    # These parameters should only be used for cache lookup. This is enforced
    # by ADAL::TokenRequest.
    #
    # @return Hash
    def request_params
      { user_id: user_id }
    end

    ##
    # Overrides comparison operator.
    #
    # @param UserIdentifier other
    # @return Boolean
    def ==(other)
      if other.respond_to? :user_id
        user_id == other.user_id
      else
        user_id == other
      end
    end
  end
end
