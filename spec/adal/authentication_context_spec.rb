require_relative '../support/fake_data'

require 'spec_helper'

# Load constants used by the fake token endpoint.
include FakeData

describe ADAL::AuthenticationContext do
  before(:each) do
    @auth_ctx = ADAL::AuthenticationContext.new(AUTHORITY, TENANT)
  end

  describe '#acquire_token_with_authorization_code' do
    it 'should return a SuccessResponse when successful' do
      token_response = @auth_ctx.acquire_token_with_authorization_code(
        RESOURCE, CLIENT_ID, CLIENT_SECRET, AUTH_CODE, REDIRECT_URI)
      expect(token_response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = @auth_ctx.acquire_token_with_authorization_code(
        RESOURCE, CLIENT_ID, CLIENT_SECRET, AUTH_CODE, 'bad')
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should fail if any of the parameters are nil' do
      expect do
        token_response = @auth_ctx.acquire_token_with_authorization_code(
          RESOURCE, CLIENT_ID, nil, AUTH_CODE, 'bad')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#acquire_token_with_client_credentials' do
    it 'should return a SuccessResponse when successful' do
      token_response = @auth_ctx.acquire_token_with_client_credentials(
        RESOURCE, CLIENT_ID, CLIENT_SECRET)
      expect(token_response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = @auth_ctx.acquire_token_with_client_credentials(
        RESOURCE, 'bad', CLIENT_SECRET)
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should fail if any of the parameters are nil' do
      expect do
        @auth_ctx.acquire_token_with_client_credentials(
          RESOURCE, CLIENT_ID, nil)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#acquire_token_with_refresh_token' do
    it 'should return a SuccessResponse when successful' do
      token_response = @auth_ctx.acquire_token_with_refresh_token(
        RESOURCE, CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, REFRESH_TOKEN)
      expect(token_response).to be_a(ADAL::SuccessResponse)
    end

    it 'should return an ErrorResponse when unauthorized' do
      token_response = @auth_ctx.acquire_token_with_refresh_token(
        RESOURCE, 'bad', CLIENT_SECRET, REDIRECT_URI, REFRESH_TOKEN)
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should return an ErrorResponse when the refresh token is invalid' do
      token_response = @auth_ctx.acquire_token_with_refresh_token(
        RESOURCE, CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, 'bad')
      expect(token_response).to be_a(ADAL::ErrorResponse)
    end

    it 'should return an ErrorResponse when the refresh token is expired' do
      fail NotImplementedError
    end

    it 'should fail if any of the parameters are nil' do
      expect do
        @auth_ctx.acquire_token_with_refresh_token(
          RESOURCE, CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, nil)
      end.to raise_error(ArgumentError)
    end
  end
end
