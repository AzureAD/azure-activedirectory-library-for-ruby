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

describe ADAL::ClientAssertionCertificate do
  describe '#initialize' do
    before(:each) do
      @auth = ADAL::Authority.new(AUTHORITY, TENANT)
      @cert = OpenSSL::X509::Certificate.new
    end

    it "should fail if the public key isn't large enough" do
      # The key is an integer number of bytes so we have to subtract at least 8.
      too_few_bits = ADAL::ClientAssertionCertificate::MIN_KEY_SIZE_BITS - 8
      key = OpenSSL::PKey::RSA.new(too_few_bits)
      @cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, @cert)
      expect do
        ADAL::ClientAssertionCertificate.new(@auth, CLIENT_ID, pfx)
      end.to raise_error(ArgumentError)
    end

    it 'should succeed if the public key is the minimum size' do
      just_enough_bits = ADAL::ClientAssertionCertificate::MIN_KEY_SIZE_BITS
      key = OpenSSL::PKey::RSA.new(just_enough_bits)
      @cert.public_key = key.public_key
      pfx = OpenSSL::PKCS12.create('', '', key, @cert)
      expect do
        ADAL::ClientAssertionCertificate.new(@auth, CLIENT_ID, pfx)
      end.to_not raise_error
    end
  end

  describe '#request_params' do
    ONE_YEAR_IN_SECONDS = 60 * 60 * 24 * 365

    before(:each) do
      key = OpenSSL::PKey::RSA.new 2048
      @cert = OpenSSL::X509::Certificate.new
      @cert.public_key = key.public_key
      @pfx = OpenSSL::PKCS12.create('', '', key, @cert)
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
      ).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
    end

    it 'should have an assertion that is a decodable JWT' do
      expect do
        JWT.decode(@assertion_cert.request_params[:client_assertion],
                   @cert.public_key,
                   options: { verify_not_before: false })
      end.to_not raise_error
    end
  end
end
