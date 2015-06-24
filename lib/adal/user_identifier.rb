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
