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

require_relative '../spec_helper'

require 'jwt'

include FakeData

describe ADAL::ClientAssertionCertificate do
  describe '#initialize' do
    let(:auth) { ADAL::Authority.new(AUTHORITY, TENANT) }
    let(:cert) { OpenSSL::X509::Certificate.new }

    it "should fail if the public key isn't large enough" do
      # The key is an integer number of bytes so we have to subtract at least 8.
      too_few_bits = ADAL::ClientAssertionCertificate::MIN_KEY_SIZE_BITS - 8
      key = OpenSSL::PKey::RSA.new(too_few_bits)
      cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, cert)
      expect do
        ADAL::ClientAssertionCertificate.new(auth, CLIENT_ID, pfx)
      end.to raise_error(ArgumentError)
    end

    it 'should succeed if the public key is the minimum size' do
      just_enough_bits = ADAL::ClientAssertionCertificate::MIN_KEY_SIZE_BITS
      key = OpenSSL::PKey::RSA.new(just_enough_bits)
      cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, cert)
      expect do
        ADAL::ClientAssertionCertificate.new(auth, CLIENT_ID, pfx)
      end.to_not raise_error
    end

    it 'should fail if the certificate is not PKCS12' do
      pfx = 'Not an OpenSSL::PKCS12'
      expect { ADAL::ClientAssertionCertificate.new(auth, CLIENT_ID, pfx) }
        .to raise_error ArgumentError
    end

    it 'should fail if the pkcs12 does not use valid rsa' do
      key = OpenSSL::PKey::DSA.new 2048
      cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, cert)
      expect { ADAL::ClientAssertionCertificate.new(auth, CLIENT_ID, pfx) }
        .to raise_error ArgumentError
    end

    it 'should fail if the pkcs12 does not use valid x509' do
      key = OpenSSL::PKey::RSA.new 2048
      cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, cert)

      # In practice, no one would ever do this. But we do check for it just in
      # case.
      pfx.instance_variable_set(:@certificate, 'Not an x509 certificate')
      expect { ADAL::ClientAssertionCertificate.new(auth, CLIENT_ID, pfx) }
        .to raise_error ArgumentError
    end
  end

  describe '#request_params' do
    ONE_YEAR_IN_SECONDS = 60 * 60 * 24 * 365
    let(:cert) { OpenSSL::X509::Certificate.new }
    before(:each) do
      key = OpenSSL::PKey::RSA.new 2048
      cert.public_key = key.public_key
      @pfx = OpenSSL::PKCS12.create('', '', key, cert)
      @assertion_cert = ADAL::ClientAssertionCertificate.new(
        ADAL::Authority.new(AUTHORITY, TENANT), CLIENT_ID, @pfx)
    end

    it 'should contain client id, client assertion and client assertion type' do
      params = @assertion_cert.request_params
      expect(params.keys).to contain_exactly(
        :client_id, :client_assertion, :client_assertion_type)
    end

    it 'should have client assertion type be JWT_BEARER' do
      expect(
        @assertion_cert.request_params[:client_assertion_type]
      ).to eq('urn:ietf:params:oauth:client-assertion-type:jwt-bearer')
    end

    it 'should have an assertion that is a decodable JWT' do
      expect do
        JWT.decode(@assertion_cert.request_params[:client_assertion],
                   cert.public_key,
                   options: { verify_not_before: false })
      end.to_not raise_error
    end
  end
end
