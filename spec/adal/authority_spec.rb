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

describe ADAL::Authority do
  let(:auth_host) { 'login.windows.net' }
  let(:tenant) { 'atenant.onmicrosoft.com' }

  describe '#token_endpoint' do
    it 'should correctly construct token endpoints' do
      auth = ADAL::Authority.new(auth_host, tenant)
      expect(auth.token_endpoint.to_s).to eq(
        "https://#{auth_host}/#{tenant}/oauth2/token")
    end
  end

  describe '#authorize_endpoint' do
    context 'with additional params' do
      it 'should correctly construct the authorize endpoint' do
        auth = ADAL::Authority.new(auth_host, tenant)
        expect(auth.authorize_endpoint(foo: :bar).to_s).to eq(
          "https://#{auth_host}/#{tenant}/oauth2/authorize?foo=bar")
      end
    end

    context 'with no additional params' do
      it 'should correctly construct the authorize endpoint' do
        auth = ADAL::Authority.new(auth_host, tenant)
        expect(auth.authorize_endpoint.to_s).to eq(
          "https://#{auth_host}/#{tenant}/oauth2/authorize")
      end
    end
  end

  describe '#validate' do
    it 'should not do anything if validate_authority was set to false in the ' \
       ' constructor' do
      auth = ADAL::Authority.new(auth_host, tenant)
      expect(auth).to_not receive(:validated_statically?)
      expect(auth).to_not receive(:validated_dynamically?)
      expect(auth.validate).to be_truthy
    end

    it 'should attempt static validation before dynamic validation' do
      auth = ADAL::Authority.new(
        auth_host, tenant, true)
      expect(auth).to receive(:validated_statically?).once.and_return true
      expect(auth).to_not receive(:validated_dynamically?)
      expect(auth.validate).to be_truthy
    end

    it 'should successfully validate statically with a well known host' do
      auth = ADAL::Authority.new(
        auth_host, tenant, true)
      expect(auth).to_not receive(:validated_dynamically?)
      expect(auth.validate).to be_truthy
    end

    it 'should successully validate dynamically with the discovery endpoint' do
      auth = ADAL::Authority.new(
        'someothersite.net', tenant, true)
      expect(Net::HTTP).to receive(:get).once.and_return('{"tenant_discovery_' \
        'endpoint": "https://login.windows.net/atenant.onmicrosoft.com/.well-' \
        'known/openid-configuration"}')
      expect(auth.validate).to be_truthy
    end

    it 'should not make a network connection after it validates once' do
      auth = ADAL::Authority.new(
        'someothersite.net', tenant, true)
      expect(Net::HTTP).to receive(:get).once.and_return(
        '{"tenant_discovery_endpoint": "endpoint"}')
      expect(auth.validate).to be_truthy
      expect(auth.validate).to be_truthy
      expect(auth.validate).to be_truthy
      expect(auth.validate).to be_truthy
    end

    it 'should be false if dynamic validation does not respond' do
      auth_host = 'notvalid.com'
      dynamic_validation_endpoint =
        'https://login.microsoftonline.com/common/discovery/instance?api-vers' \
        "ion=1.0&authorization_endpoint=https://#{auth_host}/#{tenant}/oauth2" \
        '/authorize'
      auth = ADAL::Authority.new('notvalid.com', tenant, true)
      stub_request(:get, dynamic_validation_endpoint).to_return(status: 500)
      expect(auth.validate).to be_falsey
    end

    it 'should be false if dynamic validation response is invalid' do
      auth_host = 'notvalid.com'
      dynamic_validation_endpoint =
        'https://login.microsoftonline.com/common/discovery/instance?api-vers' \
        "ion=1.0&authorization_endpoint=https://#{auth_host}/#{tenant}/oauth2" \
        '/authorize'
      auth = ADAL::Authority.new('notvalid.com', tenant, true)
      stub_request(:get, dynamic_validation_endpoint)
        .to_return(status: 200, body: '{}')
      expect(auth.validate).to be_falsey
    end
  end
end
