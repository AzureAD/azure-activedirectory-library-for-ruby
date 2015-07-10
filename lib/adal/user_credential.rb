require_relative './authority'
require_relative './logger'
require_relative './mex_request'
require_relative './token_request'
require_relative './wstrust_request'

require 'base64'
require 'json'
require 'net/http'
require 'uri'

module ADAL
  # A convenience class for username and password credentials.
  class UserCredential
    include Logging

    # Federation response type from the userrealm endpoint.
    module AccountType
      FEDERATED = 'Federated'
      MANAGED = 'Managed'
      UNKNOWN = 'Unknown'
    end

    # ADAL only supports flows for managed and federated users.
    class UnsupportedAccountTypeError < StandardError
      def initialize(account_type)
        super("Unsupported account type for authentication: #{account_type}.")
      end
    end

    attr_reader :username
    attr_reader :password

    def initialize(
      username, password, authority_host = Authority::WORLD_WIDE_AUTHORITY)
      @username = username
      @password = password
      @authority_host = authority_host
      @discovery_path = "/common/userrealm/#{URI.escape @username}"
    end

    # @return UserCredential::AccountType
    def account_type
      common_response['account_type']
    end

    # @return Hash
    def request_params
      case account_type
      when AccountType::MANAGED
        managed_request_params
      when AccountType::FEDERATED
        federated_request_params
      else
        fail UnsupportedAccountTypeError, account_type
      end
    end

    # :nocov:
    def to_s
      "UserCredential[Username: #{@username}, AccountType: #{account_type}]"
    end
    # :nocov:

    private

    # Memoized response from the common endpoint. Since a UserCredential is read
    # only, this should only ever need to be called once.
    # @return Hash
    def common_response
      @common_response ||= JSON.parse(Net::HTTP.get(common_uri))
    end

    # @return URI
    def common_uri
      URI::HTTPS.build(
        host: @authority_host,
        path: @discovery_path,
        query: URI.encode_www_form('api-version' => '1.0'))
    end

    # @return Hash
    def federated_request_params
      logger.verbose("Getting OAuth parameters for Federated #{@username}.")
      wstrust_response = wstrust_request.request(@username, @password)
      { assertion: Base64.encode64(wstrust_response.token).strip,
        grant_type: wstrust_response.grant_type,
        scope: 'openid' }
    end

    # @return URI
    def federation_metadata_url
      URI.parse(common_response['federation_metadata_url'])
    end

    # @return Hash
    def managed_request_params
      logger.verbose("Getting OAuth parameters for Managed #{@username}.")
      { username: @username,
        password: @password,
        grant_type: TokenRequest::GrantType::PASSWORD }
    end

    # @return MexResponse
    def mex_response
      @mex_response ||= MexRequest.new(federation_metadata_url).request
    end

    # @return WSTrustRequest
    def wstrust_request
      @wstrust_request ||= WSTrustRequest.new(mex_response.wstrust_url)
    end
  end
end
