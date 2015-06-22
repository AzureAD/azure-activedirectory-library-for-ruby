require_relative './authority'
require_relative './memory_cache'
require_relative './token_request'
require_relative './util'

require 'uri'

module ADAL
  # Represents a directory in AAD. Can be used for multiple clients, multiple
  # users, multiple resources and multiple means of authentication. Each
  # AuthenticationContext is specific to a tenant.
  class AuthenticationContext
    include Util

    def initialize(authority_uri, tenant, options = {})
      fail_if_arguments_nil(authority_uri, tenant)
      validate_authority = options [:validate_authority] || false
      @authority = Authority.new(authority_uri, tenant, validate_authority)
      @token_cache = options[:token_cache] || MemoryCache.new
    end

    public

    ##
    # Gets an access token using an authorization code that was obtained for the
    # resource from an authorization server.
    #
    # @return [TokenResponse]
    def acquire_token_with_authorization_code(
        resource, client_id, client_secret, auth_code, redirect_uri)
      fail_if_arguments_nil(
        resource, client_id, client_secret, auth_code, redirect_uri)
      request = TokenRequest.new(
        @authority, client_id, resource, redirect_uri: redirect_uri)
      request.get_with_authorization_code(auth_code, client_secret)
    end

    # @return [TokenResponse]
    def acquire_token_with_client_certificate(
        resource, client_id, certificate, thumbprint)
      fail_if_arguments_nil(resource, client_id, certificate, thumbprint)
      fail NotImplementedError
    end

    # @return [TokenResponse]
    def acquire_token_with_client_credentials(
        resource, client_id, client_secret)
      fail_if_arguments_nil(resource, client_id, client_secret)
      request = TokenRequest.new(@authority, client_id, resource)
      request.get_with_client_credentials(client_secret)
    end

    # @return [TokenResponse]
    def acquire_token_with_refresh_token(
        resource, client_id, client_secret, redirect_uri, refresh_token)
      fail_if_arguments_nil(
        resource, client_id, client_secret, redirect_uri, refresh_token)
      request = TokenRequest.new(
        @authority, client_id, resource, redirect_uri: redirect_uri)
      request.get_with_refresh_token(refresh_token, client_secret)
    end

    # @return [TokenResponse]
    def acquire_token_with_username_password(
      resource, client_id, username, password)
      fail_if_arguments_nil(resource, client_id, username, password)
      fail NotImplementedError
    end
  end
end
