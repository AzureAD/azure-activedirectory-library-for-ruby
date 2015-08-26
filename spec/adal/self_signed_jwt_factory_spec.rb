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

describe ADAL::SelfSignedJwtFactory do
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
        JWT.decode(@jwt, @cert.public_key)
      end.to_not raise_error
    end

    it 'should contain the correct keys in the payload' do
      payload, = JWT.decode(@jwt, @cert.public_key)
      expect(payload.keys).to contain_exactly(
        'aud', 'iss', 'sub', 'nbf', 'exp', 'jti')
    end

    it 'should containt the correct keys in the header' do
      _, header = JWT.decode(@jwt, @cert.public_key)
      expect(header.keys).to contain_exactly('x5t', 'alg', 'typ')
    end

    it 'should contain the correct thumbprint from the certificate' do
      thumbprint = OpenSSL::Digest::SHA1.new(@cert.to_der).base64digest
      _, header = JWT.decode(@jwt, @cert.public_key)
      expect(header['x5t']).to eq(thumbprint)
    end
  end
end
