module ADAL
  # Literals used in JWT header and payload.
  module JwtParameters
    ALGORITHM = 'alg'
    AUDIENCE = 'aud'
    EXPIRES_ON = 'exp'
    ISSUER = 'iss'
    JWT_ID = 'jti'
    NOT_BEFORE = 'nbf'
    RS256 = 'RS256'
    SELF_SIGNED_JWT_LIFETIME = 10
    SUBJECT = 'sub'
    THUMBPRINT = 'x5t'
    TYPE = 'typ'
    TYPE_JWT = 'JWT'
  end
end
