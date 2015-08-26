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
  # Identifier for users in the cache.
  #
  # Ideally, the application will first use a different OAuth flow, such as the
  # Authorization Code flow, to acquire an ADAL::SuccessResponse. Then, it can
  # create ADAL::UserIdentifier to query the cache which will refresh tokens as
  # necessary.
  class UserIdentifier
    attr_reader :id
    attr_reader :type

    # Displayable IDs are human readable (eg email addresses) while Unique Ids
    # are generally random UUIDs.
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
