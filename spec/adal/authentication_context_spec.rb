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
end
