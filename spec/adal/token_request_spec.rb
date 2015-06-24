require_relative '../support/fake_data'

require 'spec_helper'

include FakeData

describe ADAL::TokenRequest do
  describe '#get_with_authorization_code' do
    it 'should not make an OAuthRequest if the token is in the cache' do
      expected_response =  6
      cache = instance_double('cache', find: expected_response)
      request = ADAL::TokenRequest.new(authority, client, cache)
      expect(ADAL::OAuthRequest).to_not receive(:new)
      expect(request.get_with_authorization_code(AUTH_CODE, REDIRECT_URI))
        .to eq(expected_response)
    end

    it 'should make an OAuthRequest if the token is not in the cache' do
      expected_response = 7
      allow(ADAL::OAuthRequest).to receive(:new).and_return(
        mock_request(expected_response))
      request = ADAL::TokenRequest.new(authority, client)
      expect(ADAL::OAuthRequest).to receive(:new).once
      expect(request.get_with_authorization_code(AUTH_CODE, REDIRECT_URI))
        .to eq(expected_response)
    end
  end

  describe '#get_for_client' do
    it 'should not make an OAuthRequest if the token is in the cache' do
      expected_response =  6
      cache = instance_double('cache', find: expected_response)
      request = ADAL::TokenRequest.new(authority, client, cache)
      expect(ADAL::OAuthRequest).to_not receive(:new)
      expect(request.get_for_client(RESOURCE)).to eq(expected_response)
    end

    it 'should make an OAuthRequest if the token is not in the cache' do
      expected_response = 7
      allow(ADAL::OAuthRequest).to receive(:new).and_return(
        mock_request(expected_response))
      request = ADAL::TokenRequest.new(authority, client)
      expect(ADAL::OAuthRequest).to receive(:new).once
      expect(request.get_for_client(RESOURCE)).to eq(expected_response)
    end
  end

  describe '#get_with_refresh_token' do
    it 'should not make an OAuthRequest if the token is in the cache' do
      expected_response =  6
      cache = instance_double('cache', find: expected_response)
      request = ADAL::TokenRequest.new(authority, client, cache)
      expect(ADAL::OAuthRequest).to_not receive(:new)
      expect(request.get_with_refresh_token(REFRESH_TOKEN, RESOURCE))
        .to eq(expected_response)
    end

    it 'should make an OAuthRequest if the token is not in the cache' do
      expected_response = 7
      allow(ADAL::OAuthRequest).to receive(:new).and_return(
        mock_request(expected_response))
      request = ADAL::TokenRequest.new(authority, client)
      expect(ADAL::OAuthRequest).to receive(:new).once
      expect(request.get_with_refresh_token(REFRESH_TOKEN))
        .to eq(expected_response)
    end
  end

  def authority
    ADAL::Authority.new(AUTHORITY, TENANT)
  end

  def client
    ADAL::ClientCredential.new(CLIENT_ID, CLIENT_SECRET)
  end

  def mock_request(result = nil)
    instance_double('oauth_request', get: result)
  end
end
