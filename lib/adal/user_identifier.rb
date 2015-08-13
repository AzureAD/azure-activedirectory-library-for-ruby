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
    attr_reader :unique_id
    attr_reader :displayable_id
    attr_reader :type

    module Type
      UNIQUE_ID = :UNIQUE_ID
      DISPLAYABLE_ID = :DISPLAYABLE_ID
    end

    ##
    # Creates a UserIdentifier with a specific type. Used for cache lookups.
    # Matches .NET ADAL implementation.
    #
    # @param String id
    # @param UserIdentifier::Type
    # @return ADAL::UserIdentifier
    def self.create(id, type)
      case type
      when Type::UNIQUE_ID
        ADAL::UserIdentifier.new(type: type, unique_id: id)
      when TYPE::DISPLAYABLE_ID
        ADAL::UserIdentifier.new(type: type, displayable_id: id)
      end
    end

    ##
    # Constructs a new UserIdentifier from a set of claims. Developers should
    # not use this method. Instead, please use ::create(id, type) to specify
    # the user id and the type.
    #
    # @param Hash claims
    #   Claims from an id token. The exact claims will vary, so whatever is not
    #   found in the claims will be nil.
    def initialize(claims)
      claims.each { |k, v| instance_variable_set("@#{k}", v) }
      @unique_id = oid || sub || unique_id
      @displayable_id = upn || email || displayable_id
    end

    ##
    # Does the UserIdentifier contain a displayable id?
    #
    # @return Boolean
    def displayable?
      !@displayable_id.nil?
    end

    ##
    # Does the UserIdentifier contain a unique id
    #
    # @return Boolean
    def unique?
      !@unique_id.nil?
    end

    ##
    # These parameters should only be used for cache lookup. This is enforced
    # by ADAL::TokenRequest.
    #
    # @return Hash
    def request_params
      { unique_id: unique_id,
        displayable_id: displayable_id }
    end

    ##
    # Overrides comparison operator.
    #
    # @param UserIdentifier other
    # @return Boolean
    def ==(other)
      if other.respond_to?(:unique_id) && other.unique_id
        unique_id == other.unique_id
      elsif other.respond_to?(:displayable_id) && other.displayable_id
        displayable_id == other.displayable_id
      else
        (self.equal? other) || displayable_id == other
      end
    end
  end
end
