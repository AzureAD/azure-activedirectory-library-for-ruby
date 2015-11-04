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

    ##
    # Constructs a new UserCredential.
    #
    # @param String username
    # @param String password
    # @optional String authority_host
    #   The host name of the authority to verify the user against.
    def initialize(
      username, password, authority_host = Authority::WORLD_WIDE_AUTHORITY)
      @username = username
      @password = password
      @authority_host = authority_host
      @discovery_path = "/common/userrealm/#{URI.escape @username}"
    end

    ##
    # Determines the account type based on a Home Realm Discovery request.
    #
    # @return UserCredential::AccountType
    def account_type
      realm_discovery_response['account_type']
    end

    ##
    # The OAuth parameters that respresent this UserCredential.
    #
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

    # Memoized response from the discovery endpoint. Since a UserCredential is
    # read only, this should only ever need to be called once.
    # @return Hash
    def realm_discovery_response
      @realm_discovery_response ||=
        JSON.parse(Net::HTTP.get(realm_discovery_uri))
    end

    # @return URI
    def realm_discovery_uri
      URI::HTTPS.build(
        host: @authority_host,
        path: @discovery_path,
        query: URI.encode_www_form('api-version' => '1.0'))
    end

    # @return Hash
    def federated_request_params
      logger.verbose("Getting OAuth parameters for Federated #{@username}.")
      wstrust_response = wstrust_request.execute(@username, @password)
      { assertion: Base64.encode64(wstrust_response.token).strip,
        grant_type: wstrust_response.grant_type,
        scope: :openid }
    end

    # @return URI
    def federation_metadata_url
      URI.parse(realm_discovery_response['federation_metadata_url'])
    end

    # @return Hash
    def managed_request_params
      logger.verbose("Getting OAuth parameters for Managed #{@username}.")
      { username: @username,
        password: @password,
        grant_type: TokenRequest::GrantType::PASSWORD,
        scope: :openid }
    end

    # @return MexResponse
    def mex_response
      @mex_response ||= MexRequest.new(federation_metadata_url).execute
    end

    # @return WSTrustRequest
    def wstrust_request
      @wstrust_request ||=
        WSTrustRequest.new(mex_response.wstrust_url, mex_response.action)
    end
  end
end
