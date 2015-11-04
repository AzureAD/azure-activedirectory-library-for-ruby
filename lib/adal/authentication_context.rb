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

using ADAL::CoreExt

module ADAL
  # Retrieves authentication tokens from Azure Active Directory and ADFS
  # services. For most users, this is the primary class to authenticate an
  # application.
  class AuthenticationContext
    include RequestParameters
    include Util

    ##
    # Creates a new AuthenticationContext.
    #
    # @param String authority_host
    #   The host name of the authority to verify against, e.g.
    #   'login.windows.net'.
    # @param String tenant
    #   The tenant to authenticate to, e.g. 'contoso.onmicrosoft.com'.
    # @optional Boolean validate_authority
    #   Whether the authority should be checked for validity before making
    #   token requests. Defaults to false.
    # @optional TokenCache token_cache
    #   An cache that ADAL will use to store access tokens and refresh tokens
    #   in. By default an empty in-memory cache is created. An existing cache
    #   can be used to data persistence.
    def initialize(authority_host = Authority::WORLD_WIDE_AUTHORITY,
                   tenant = Authority::COMMON_TENANT,
                   options = {})
      fail_if_arguments_nil(authority_host, tenant)
      validate_authority = options[:validate_authority] || false
      @authority = Authority.new(authority_host, tenant, validate_authority)
      @token_cache = options[:token_cache] || MemoryCache.new
    end

    public

    ##
    # Gets an access token with only the clients credentials and no user
    # information.
    #
    # @param String resource
    #   The resource being requested.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   An object that validates the client application by adding
    #   #request_params to the OAuth request.
    # @return TokenResponse
    def acquire_token_for_client(resource, client_cred)
      fail_if_arguments_nil(resource, client_cred)
      token_request_for(client_cred).get_for_client(resource)
    end

    ##
    # Gets an access token with a previously acquire authorization code.
    #
    # @param String auth_code
    #   The authorization code that was issued by the authorization server.
    # @param URI redirect_uri
    #   The URI that was passed to the authorization server with the request
    #   for the authorization code.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   An object that validates the client application by adding
    #   #request_params to the OAuth request.
    # @optional String resource
    #   The resource being requested.
    # @return TokenResponse
    def acquire_token_with_authorization_code(
      auth_code, redirect_uri, client_cred, resource = nil)
      fail_if_arguments_nil(auth_code, redirect_uri, client_cred)
      token_request_for(client_cred)
        .get_with_authorization_code(auth_code, redirect_uri, resource)
    end

    ##
    # Gets an access token using a previously acquire refresh token.
    #
    # @param String refresh_token
    #   The previously acquired refresh token.
    # @param String|ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   The client application can be validated in four different manners,
    #   depending on the OAuth flow. This object must support #request_params.
    # @optional String resource
    #   The resource being requested.
    # @return TokenResponse
    def acquire_token_with_refresh_token(
      refresh_token, client_cred, resource = nil)
      fail_if_arguments_nil(refresh_token, client_cred)
      token_request_for(client_cred)
        .get_with_refresh_token(refresh_token, resource)
    end

    ##
    # Gets an acccess token with a previously acquired user token.
    # Gets an access token for a specific user. This method is relevant for
    # three authentication scenarios:
    #
    # 1. Username/Password flow:
    # Pass in the username and password wrapped in an ADAL::UserCredential.
    #
    # 2. On-Behalf-Of flow:
    # This allows web services to accept access tokens users and then exchange
    # them for access tokens for a different resource. Note that to use this
    # flow you must properly configure permissions settings in the Azure web
    # portal. Pass in the access token wrapped in an ADAL::UserAssertion.
    #
    # 3. User Identifier flow:
    # This will not make any network connections but will merely check the cache
    # for existing tokens matching the request.
    #
    # @param String resource
    #   The intended recipient of the requested token.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   An object that validates the client application by adding
    #   #request_params to the OAuth request.
    # @param UserAssertion|UserCredential|UserIdentifier
    #   An object that validates the client that the requested access token is
    #   for. See the description above of the various flows.
    # @return TokenResponse
    def acquire_token_for_user(resource, client_cred, user)
      fail_if_arguments_nil(resource, client_cred, user)
      token_request_for(client_cred)
        .get_with_user_credential(user, resource)
    end

    ##
    # Constructs a URL for an authorization endpoint using query parameters.
    #
    # @param String resource
    #   The intended recipient of the requested token.
    # @param String client_id
    #   The identifier of the calling client application.
    # @param URI redirect_uri
    #   The URI that the the authorization code should be sent back to.
    # @optional Hash extra_query_params
    #   Any remaining query parameters to add to the URI.
    # @return URI
    def authorization_request_url(
      resource, client_id, redirect_uri, extra_query_params = {})
      @authority.authorize_endpoint(
        extra_query_params.reverse_merge(
          client_id: client_id,
          response_mode: FORM_POST,
          redirect_uri: redirect_uri,
          resource: resource,
          response_type: CODE))
    end

    ##
    # Sets the correlation id that will be used in all future request headers
    # and logs.
    #
    # @param String value
    #   The UUID to use as the correlation for all subsequent requests.
    def correlation_id=(value)
      Logging.correlation_id = value
    end

    private

    # Helper function for creating token requests based on client credentials
    # and the current authentication context.
    def token_request_for(client_cred)
      TokenRequest.new(@authority, wrap_client_cred(client_cred), @token_cache)
    end

    def wrap_client_cred(client_cred)
      if client_cred.is_a? String
        ClientCredential.new(client_cred)
      else
        client_cred
      end
    end
  end
end
