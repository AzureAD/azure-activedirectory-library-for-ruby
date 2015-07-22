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

require_relative '../support/fake_data'

require 'spec_helper'

include FakeData

describe ADAL::TokenRequest do
  let(:authority) { ADAL::Authority.new(AUTHORITY, TENANT) }
  let(:cache) { ADAL::MemoryCache.new }
  let(:client) { ADAL::ClientCredential.new(CLIENT_ID, CLIENT_SECRET) }
  let(:token_request) { ADAL::TokenRequest.new(authority, client, cache) }
  let(:token_response) do
    ADAL::SuccessResponse.new(expires_in: 100, resource: RESOURCE)
  end

  # The mocking seam is the OAuthRequest class.
  def mock_oauth_request(result = nil)
    instance_double('oauth_request', execute: result)
  end

  describe '#get_with_authorization_code' do
    context 'with a matching token in the cache' do
      before(:each) do
        ADAL::CacheDriver.new(authority, client, cache).add(token_response)
      end

      it 'should not make an OAuthRequest' do
        expect(ADAL::OAuthRequest).to_not receive(:new)
        token_request.get_with_authorization_code(
          AUTH_CODE, REDIRECT_URI, RESOURCE)
      end

      it 'should retrieve the token response from the cache' do
        expect(
          token_request.get_with_authorization_code(
            AUTH_CODE, REDIRECT_URI, RESOURCE)
        ).to eq(token_response)
      end
    end

    context 'without a matching token in the cache' do
      before(:each) do
        allow(ADAL::OAuthRequest).to receive(:new)
          .and_return(mock_oauth_request(token_response))
      end

      it 'should make an OAuthRequest' do
        expect(ADAL::OAuthRequest).to receive(:new).once
        token_request.get_with_authorization_code(AUTH_CODE, REDIRECT_URI)
      end

      it 'should return the token response from the OAuth flow' do
        expect(
          token_request.get_with_authorization_code(AUTH_CODE, REDIRECT_URI)
        ).to eq(token_response)
      end
    end
  end

  describe '#get_for_client' do
    context 'with a matching token in the cache' do
      before(:each) do
        ADAL::CacheDriver.new(authority, client, cache).add(token_response)
      end

      it 'should not make an OAuthRequest' do
        expect(ADAL::OAuthRequest).to_not receive(:new)
        token_request.get_for_client(RESOURCE)
      end

      it 'should retrieve the token response from the cache' do
        expect(token_request.get_for_client(RESOURCE)).to eq(token_response)
      end
    end

    context 'without a matching token in the cache' do
      before(:each) do
        allow(ADAL::OAuthRequest).to receive(:new)
          .and_return(mock_oauth_request(token_response))
      end

      it 'should make an OAuthRequest' do
        expect(ADAL::OAuthRequest).to receive(:new).once
        token_request.get_for_client(RESOURCE)
      end

      it 'should return the token response from the OAuth flow' do
        expect(token_request.get_for_client(RESOURCE)).to eq(token_response)
      end
    end
  end

  describe '#get_with_refresh_token' do
    let(:refresh_token_response) { ADAL::SuccessResponse.new }
    before(:each) do
      allow(ADAL::OAuthRequest).to receive(:new)
        .and_return(mock_oauth_request(refresh_token_response))
    end

    context 'with a matching token in the cache' do
      before(:each) do
        ADAL::CacheDriver.new(authority, client, cache).add(token_response)
      end

      it 'should make an OAuth request' do
        expect(ADAL::OAuthRequest).to receive(:new).once
        token_request.get_with_refresh_token(REFRESH_TOKEN, RESOURCE)
      end

      it 'should return the refreshed token response' do
        expect(token_request.get_with_refresh_token(REFRESH_TOKEN, RESOURCE))
          .to eq(refresh_token_response)
      end
    end

    context 'without a matching token in the cache' do
      it 'should make an OAuth request' do
        expect(ADAL::OAuthRequest).to receive(:new).once
        token_request.get_with_refresh_token(REFRESH_TOKEN, RESOURCE)
      end

      it 'should return the refreshed token response' do
        expect(token_request.get_with_refresh_token(REFRESH_TOKEN, RESOURCE))
          .to eq(refresh_token_response)
      end
    end
  end
end
