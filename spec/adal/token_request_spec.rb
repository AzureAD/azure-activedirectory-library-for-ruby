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

  describe '#get_with_device_code' do
    context 'with a matching token in the cache' do
      before(:each) do
        ADAL::CacheDriver.new(authority, client, cache).add(token_response)
      end

      it 'should not make an OAuthRequest' do
        expect(ADAL::OAuthRequest).to_not receive(:new)
        token_request.get_with_device_code(
          DEVICE_CODE, RESOURCE)
      end

      it 'should retrieve the token response from the cache' do
        expect(
          token_request.get_with_device_code(
            DEVICE_CODE, RESOURCE)
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
        token_request.get_with_device_code(DEVICE_CODE)
      end

      it 'should return the token response from the OAuth flow' do
        expect(
          token_request.get_with_device_code(DEVICE_CODE)
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
