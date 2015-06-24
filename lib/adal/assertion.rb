module ADAL
  # Mix-in module including all supported assertion types.
  module Assertion
    JWT_BEARER = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'

    ALL_TYPES = [JWT_BEARER]
  end
end
