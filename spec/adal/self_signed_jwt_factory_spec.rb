require_relative '../spec_helper'

require 'jwt'

include FakeData

describe ADAL::SelfSignedJwtFactory do
  # Note: There is an off-by-one error in JWT::decode in ruby-jwt. I've
  # submitted a fix at https://github.com/progrium/ruby-jwt/pull/88.
  # If that fix is submitted, we can remove the options hases from each of the
  # decoding method calls in this file.
  describe '#create_and_sign_jwt' do
    before(:each) do
      key = OpenSSL::PKey::RSA.new 2048
      @cert = OpenSSL::X509::Certificate.new
      @cert.public_key = key.public_key
      @jwt = ADAL::SelfSignedJwtFactory
             .new(CLIENT_ID, 'some_token_endpoint')
             .create_and_sign_jwt(@cert, key)
    end

    it 'should be decodable with the public key' do
      expect do
        JWT.decode(@jwt, @cert.public_key, options: { leeway: 1 })
      end.to_not raise_error
    end

    it 'should contain the correct keys in the payload' do
      payload, = JWT.decode(@jwt, @cert.public_key, options: { leeway: 1 })
      expect(payload.keys).to contain_exactly(
        'aud', 'iss', 'sub', 'nbf', 'exp', 'jti')
    end

    it 'should containt the correct keys in the header' do
      _, header = JWT.decode(@jwt, @cert.public_key, options: { leeway: 1 })
      expect(header.keys).to contain_exactly('x5t', 'alg', 'typ')
    end

    it 'should contain the correct thumbprint from the certificate' do
      thumbprint = OpenSSL::Digest::SHA1.new(@cert.to_der).base64digest
      _, header = JWT.decode(@jwt, @cert.public_key, options: { leeway: 1 })
      expect(header['x5t']).to eq(thumbprint)
    end
  end
end
