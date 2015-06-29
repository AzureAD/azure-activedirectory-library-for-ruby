require_relative './authority'
require_relative './core_ext'
require_relative './memory_cache'
require_relative './request_parameters'
require_relative './token_request'
require_relative './util'

require 'securerandom'
require 'uri'

using ADAL::CoreExt

module ADAL
  # Retrieves authentication tokens from Azure Active Directory and ADFS
  # services. For most users, this is the primary class to authenticate an
  # application.
  class AuthenticationContext
    include RequestParameters
    include Util

    # The read method is nontrivial so it cannot be defined with a macro.
    attr_writer :next_correlation_id

    def initialize(authority_uri, tenant, options = {})
      fail_if_arguments_nil(authority_uri, tenant)
      validate_authority = options [:validate_authority] || false
      @authority = Authority.new(authority_uri, tenant, validate_authority)
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
    # @return [TokenResponse]
    def acquire_token_for_client(resource, client_cred)
      fail_if_arguments_nil(resource, client_cred)
      with_correlation_id do
        token_request_for(client_cred).get_for_client(resource)
      end
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
    # @return [TokenResponse]
    def acquire_token_with_authorization_code(
      auth_code, redirect_uri, client_cred, resource = nil)
      fail_if_arguments_nil(auth_code, redirect_uri, client_cred)
      with_correlation_id do
        token_request_for(client_cred)
          .get_with_authorization_code(auth_code, redirect_uri, resource)
      end
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
    # @return [TokenResponse]
    def acquire_token_with_refresh_token(
      refresh_token, client_cred, resource = nil)
      fail_if_arguments_nil(refresh_token, client_cred)
      with_correlation_id do
        token_request_for(client_cred)
          .get_with_refresh_token(refresh_token, resource)
      end
    end

    ##
    # Gets an acccess token with a previously acquired user token.
    #
    # @param String resource
    #   The intended recipient of the requested token.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   An object that validates the client application by adding
    #   #request_params to the OAuth request.
    # @param UserAssertion
    #   The previously acquire user token.
    # @return [TokenResponse]
    def acquire_token_on_behalf(resource, client_cred, user_assertion)
      fail_if_arguments_nil(resource, client_cred, user_assertion)
      fail NotImplementedError
    end

    ##
    # Gets a security token without prompting for user credentials but instead
    # just supplying an identifier.
    #
    # @param String resource
    #   The intended recipient of the requested token.
    # @param ClientCredential|ClientAssertion|ClientAssertionCertificate
    #   An object that validates the client application by adding
    #   #request_params to the OAuth request.
    # @param UserIdentifier user_id
    #   The identifier of the user that the token is being requested for.
    # @return [TokenResponse]
    def acquire_token_with_username_identifier(resource, client_cred, user_id)
      fail_if_arguments_nil(resource, client_cred, user_id)
      fail NotImplementedError
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

    # The correlation id that will be used on the next request. It can be set
    # with the attribute writer, but it is not necessary to use ADAL.
    def next_correlation_id
      @next_correlation_id ||= SecureRandom.uuid
    end

    private

    # Returns the current next_correlation_id and resets it so that it cannot be
    # used again. There is no reason for a client to use this.
    def next_correlation_id!
      temp = next_correlation_id
      @next_correlation_id = SecureRandom.uuid
      temp
    end

    # Helper function for creating token requests based on client credentials
    # and the current authentication context.
    def token_request_for(client_cred)
      TokenRequest.new(@authority, wrap_client_cred(client_cred))
    end

    # Sets the correlation_id on the logger for the duration of the call.
    def with_correlation_id
      Logging.correlation_id = next_correlation_id!
      result = yield
      Logging.remove_correlation_id
      result
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
