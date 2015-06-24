require 'openssl'

module ADAL
  # An assertion made by a client with an X509 certificate.
  class ClientAssertionCertificate
    MIN_KEY_SIZE_BITS = 2014

    attr_reader :certificate
    attr_reader :client_id

    ##
    # Creates a new ClientAssertionCertificate.
    #
    # @param [String] client_id
    #   The client id of the calling application.
    # @param [OpenSSL::X509::Certificate] certificate
    #   The certificate being used as a client credential.
    def initialize(client_id, certificate)
      if !certificate.is_a? OpenSSL::X509::Certificate
        fail ArgumentError, 'certificate must be an OpenSSL::X509::Certificate'
      elsif public_key_size_bits(certificate) < MIN_KEY_SIZE_BITS
        fail ArgumentError, 'certificate must contain a public key of at ' \
          "least #{MIN_KEY_SIZE_BITS} bits."
      end
      @certificate = certificate
      @client_id = client_id.to_s
    end

    # The relevant parameters from this credential for OAuth.
    def request_params
      fail NotImplementedError
    end

    ##
    # Sign a message with the certificate.
    #
    # @param [String] message
    def sign
      fail NotImplementedError
    end

    private

    # @param [OpenSSL::X509::Certificate] certificate
    # @return [Fixnum] The number of bits in the public key.
    def public_key_size_bits(certificate)
      certificate.public_key.n.num_bytes * 8
    end
  end
end
