require 'openssl'

module ADAL
  # An assertion made by a client with an X509 certificate. This requires both
  # the public and private keys. Technically it only requires the thumbprint
  # of the public key, however OpenSSL's object model does not include
  # thumbprints.
  class ClientAssertionCertificate
    include RequestParameters

    MIN_KEY_SIZE_BITS = 2014

    attr_reader :certificate
    attr_reader :client_id

    ##
    # Creates a new ClientAssertionCertificate.
    #
    # @param Authority authority
    #   The authority object that will recognize this certificate.
    # @param [String] client_id
    #   The client id of the calling application.
    # @param [OpenSSL::X509::Certificate] certificate
    #   The client's public certificate.
    # @param [OpenSSL::PKey::RSA] private_key
    #   The client's private key.
    def initialize(authority, client_id, certificate, private_key)
      validate_certificate_and_key(certificate, private_key)
      @authority = authority
      @certificate = certificate
      @client_id = client_id.to_s
      @private_key = private_key
    end

    # The relevant parameters from this credential for OAuth.
    def request_params
      jwt_assertion = SelfSignedJwtFactory
                      .new(@client_id, @authority.token_endpoint)
                      .create_and_sign_jwt(@certificate, @private_key)
      ClientAssertion.new(client_id, jwt_assertion).request_params
    end

    private

    # @param [OpenSSL::X509::Certificate] certificate
    # @return [Fixnum] The number of bits in the public key.
    def public_key_size_bits(certificate)
      certificate.public_key.n.num_bytes * 8
    end

    ##
    # In general, Ruby code is very loose about types. However, since we are
    # dealing with sensitive information here, we will be a little bit stricter
    # on type safety.
    def validate_certificate_and_key(certificate, private_key)
      if !certificate.is_a? OpenSSL::X509::Certificate
        fail ArgumentError, 'certificate must be an OpenSSL::X509::Certificate.'
      elsif !private_key.is_a? OpenSSL::PKey::RSA
        fail ArgumentError, 'private_key must be an OpenSSL::PKey::RSA.'
      elsif public_key_size_bits(certificate) < MIN_KEY_SIZE_BITS
        fail ArgumentError, 'certificate must contain a public key of at ' \
          "least #{MIN_KEY_SIZE_BITS} bits."
      end
    end
  end
end
