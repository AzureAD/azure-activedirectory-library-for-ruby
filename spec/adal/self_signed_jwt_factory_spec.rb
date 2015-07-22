#-------------------------------------------------------------------------------
# # Copyright (c) Microsoft Open Technologies, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
# ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
# PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
#
# See the Apache License, Version 2.0 for the specific language
# governing permissions and limitations under the License.
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
