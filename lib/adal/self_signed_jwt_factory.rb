require_relative './jwt_parameters'
require_relative './logging'

require 'jwt'
require 'openssl'
require 'securerandom'

module ADAL
  # Converts client certificates into self signed JWTs.
  class SelfSignedJwtFactory
    include JwtParameters
    include Logging

    ##
    # Constructs a new SelfSignedJwtFactory.
    #
    # @param String client_id
    #   The client id of the calling application.
    # @param String token_endpoint
    #   The token endpoint that will accept the certificate.
    def initialize(client_id, token_endpoint)
      @client_id = client_id
      @token_endpoint = token_endpoint
    end

    ##
    # Creates a JWT from a client certificate and signs it with a private key.
    #
    # @param OpenSSL::X509::Certificate certificate
    #   The certifcate object to be converted to a JWT and signed for use
    #   in an authentication flow.
    # @param OpenSSL::PKey::RSA private_key
    #   The private key used to sign the certificate.
    # @return String
    def create_and_sign_jwt(certificate, private_key)
      JWT.encode(payload, private_key, RS256, header(certificate))
    end

    private

    # The JWT header for a certificate to be encoded.
    def header(certificate)
      x5t = thumbprint(certificate)
      logger.verbose("Creating self signed JWT header with thumbprint: #{x5t}.")
      { TYPE => TYPE_JWT,
        ALGORITHM => RS256,
        THUMBPRINT => x5t }
    end

    # The JWT payload.
    def payload
      now = Time.now - 1
      expires = now + 60 * SELF_SIGNED_JWT_LIFETIME
      logger.verbose("Creating self signed JWT payload. Expires: #{expires}. " \
                     "NotBefore: #{now}.")
      { AUDIENCE => @token_endpoint,
        ISSUER => @client_id,
        SUBJECT => @client_id,
        NOT_BEFORE => now.to_i,
        EXPIRES_ON => expires.to_i,
        JWT_ID => SecureRandom.uuid }
    end

    ##
    # Base 64 encoded thumbprint AKA fingerprint AKA SHA1 hash of the
    # DER representation of the cert.
    #
    # @param OpenSSL::X509::Certificate certificate
    # @return String
    def thumbprint(certificate)
      OpenSSL::Digest::SHA1.new(certificate.to_der).base64digest
    end
  end
end
