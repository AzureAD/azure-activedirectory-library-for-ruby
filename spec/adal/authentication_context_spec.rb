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

# Load constants used by the fake token endpoint.
include FakeData

describe ADAL::AuthenticationContext do
  let(:auth_ctx) { ADAL::AuthenticationContext.new(AUTHORITY, TENANT) }
  let(:client_cred) { ADAL::ClientCredential.new(CLIENT_ID, CLIENT_SECRET) }

  describe '#authorization_request_url' do
    let(:resource) { 'http://graph.windows.net' }
    let(:client_id) { 'some-client-id' }
    let(:redirect_uri) { 'http://contoso.com/login' }

    context 'with no extra params' do
      it 'should produce the correct request url' do
        authorization_url =
          auth_ctx.authorization_request_url(resource, client_id, redirect_uri)
        expect(authorization_url.to_s.strip)
          .to eq "https://#{AUTHORITY}/#{TENANT}/oauth2/authorize?client_id=" \
                 "#{client_id}&response_mode=form_post&redirect_uri=http%3A%2" \
                 'F%2Fcontoso.com%2Flogin&resource=http%3A%2F%2Fgraph.windows' \
                 '.net&response_type=code'
      end
    end

    context 'with extra params' do
      it 'should produce the correct request url' do
        params = { foo: :bar }
        authorization_url = auth_ctx.authorization_request_url(
          resource, client_id, redirect_uri, params)
        expect(authorization_url.to_s.strip)
          .to eq "https://#{AUTHORITY}/#{TENANT}/oauth2/authorize?client_id=" \
                 "#{client_id}&response_mode=form_post&redirect_uri=http%3A%2" \
                 'F%2Fcontoso.com%2Flogin&resource=http%3A%2F%2Fgraph.windows' \
                 '.net&response_type=code&foo=bar'
      end
    end
  end

  describe '#correlation_id=' do
    let(:correlation_id) { 'correlation_id_1' }
    let(:user) { ADAL::UserAssertion.new(USER_ASSERTION) }

    it 'should put the correlation id on all request headers' do
      auth_ctx.correlation_id = correlation_id
      stub_request(:post, %r{.*#{TENANT}\/oauth2\/token})
        .with(headers: { 'client-request-id' => correlation_id })
        .and_return(body: '{"access_token":"my access token"}')
      result = auth_ctx.acquire_token_for_user(RESOURCE, CLIENT_ID, user)
      expect(result.access_token).to eq('my access token')
    end
  end

  describe '#acquire_token_with_authorization_code' do
    it 'should return a SuccessResponse when successful' do
      token_response = auth_ctx.acquire_token_with_authorization_code(
        AUTH_CODE, REDIRECT_URI, client_cred, RESOURCE)
      expect(token_response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = auth_ctx.acquire_token_with_authorization_code(
        AUTH_CODE, 'bad', client_cred, RESOURCE)
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should fail if any of the required parameters are nil' do
      expect do
        auth_ctx.acquire_token_with_authorization_code(
          nil, REDIRECT_URI, client_cred, RESOURCE)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#acquire_token_for_client' do
    it 'should return a SuccessResponse when successful' do
      response = auth_ctx.acquire_token_for_client(RESOURCE, client_cred)
      expect(response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = auth_ctx.acquire_token_for_client(RESOURCE, 'bad')
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should fail if any of the parameters are nil' do
      expect do
        auth_ctx.acquire_token_for_client(RESOURCE, nil)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#acquire_token_with_refresh_token' do
    it 'should return a SuccessResponse when successful' do
      token_response = auth_ctx.acquire_token_with_refresh_token(
        REFRESH_TOKEN, client_cred, RESOURCE)
      expect(token_response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = auth_ctx.acquire_token_with_refresh_token(
        REFRESH_TOKEN, 'bad', RESOURCE)
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should return an ErrorResponse when the refresh token is invalid' do
      token_response = auth_ctx.acquire_token_with_refresh_token(
        'bad', client_cred, RESOURCE)
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should fail if any of the required parameters are nil' do
      expect do
        auth_ctx.acquire_token_with_refresh_token(
          nil, client_cred, RESOURCE)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#acquire_token_for_user' do
    context 'with valid parameters' do
      let(:user) { ADAL::UserAssertion.new(USER_ASSERTION) }
      subject { auth_ctx.acquire_token_for_user(RESOURCE, client_cred, user) }

      it { is_expected.to be_a(ADAL::SuccessResponse) }
    end

    context 'with invalid parameters' do
      it 'should fail' do
        expect { auth_ctx.acquire_token_for_user(nil, nil) }
          .to raise_error(ArgumentError)
      end
    end

    context 'with a UserIdentifier' do
      let(:user) { ADAL::UserIdentifier.new(USERNAME, :DISPLAYABLE_ID) }
      context 'with a matching token in the cache' do
        subject { auth_ctx.acquire_token_for_user(RESOURCE, client_cred, user) }
        before(:each) do
          @first_response = auth_ctx.acquire_token_with_authorization_code(
            AUTH_CODE, REDIRECT_URI, client_cred, RESOURCE)
        end

        it { is_expected.to_not be nil }

        it 'should return the token from the cache' do
          expect(subject).to eq @first_response
        end
      end

      context 'with no matching token in the cache' do
        subject do
          -> { auth_ctx.acquire_token_for_user(RESOURCE, client_cred, user) }
        end
        it do
          is_expected.to raise_error ADAL::TokenRequest::UserCredentialError
        end
      end
    end
  end
end
