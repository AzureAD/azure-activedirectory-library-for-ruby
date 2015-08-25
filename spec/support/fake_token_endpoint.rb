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

require_relative './fake_data'

require 'json'
require 'jwt'
require 'sinatra/base'

# A token endpoint that only recognizes one tenant and client id.
class FakeTokenEndpoint < Sinatra::Base
  include FakeData

  # Taken from RFC 6749 4.1.2.1.
  module ErrorResponseCodes
    INVALID_REQUEST = 'invalid_request'
    INVALID_CLIENT = 'invalid_client'
    INVALID_GRANT = 'invalid_grant'
    UNAUTHORIZED_CLIENT = 'unauthorized_client'
    UNSUPPORTED_GRANT_TYPE = 'unsupported_grant_type'
  end

  DEFAULT_EXPIRATION = 3600
  DEFAULT_ID_TOKEN = JWT.encode({ email: USERNAME }, '')
  DEFAULT_TOKEN_TYPE = 'Bearer'

  post '/:tenant/oauth2/token' do
    if TENANT != params[:tenant] || CLIENT_ID != params[:client_id]
      error_oauth_response(ErrorResponseCodes::INVALID_CLIENT)
    elsif params.key?('code') && AUTH_CODE == params['code'] &&
          REDIRECT_URI == params['redirect_uri']
      successful_oauth_response
    elsif params['code']
      error_oauth_response(ErrorResponseCodes::INVALID_GRANT)
    elsif params['refresh_token'] && REFRESH_TOKEN == params['refresh_token']
      successful_oauth_response
    elsif params['refresh_token']
      error_oauth_response(ErrorResponseCodes::UNAUTHORIZED_CLIENT)
    elsif params['client_secret'] && CLIENT_SECRET == params['client_secret']
      successful_oauth_response
    elsif params.key? 'client_secret'
      error_oauth_response(ErrorResponseCodes::INVALID_CLIENT)
    else
      error_oauth_response(ErrorResponseCodes::INVALID_REQUEST)
    end
  end

  private

  def error_oauth_response(code, description = 'Error from fake endpoint')
    { error: code, error_description: description }.to_json
  end

  def oauth_response(tenant)
    { access_token: 'test_access_token',
      token_type: 'BEARER',
      tenant: tenant
    }
  end

  def successful_oauth_response(opts = {})
    res = { access_token: opts[:access_token] || RETURNED_TOKEN,
            token_type: opts[:token_type] || DEFAULT_TOKEN_TYPE,
            id_token: opts[:id_token] || DEFAULT_ID_TOKEN,
            resource: params[:resource],
            expires_in: opts[:expires_in] || DEFAULT_EXPIRATION }
    res[:refresh_token] = opts[:refresh_token] if opts.key? :refresh_token
    res.to_json
  end

  def try_auth_code(data, params)
    return unless params.key? 'code'
    if (data['codes'].key? params[:code]) &&
       data['codes'][params['code']] == params[:redirect_uri]
      successful_oauth_response
    else
      error_oauth_response(ErrorResponseCodes::INVALID_GRANT)
    end
  end

  def try_client_secret(data, params)
    return unless params.key? 'client_secret'
    if data['client_secret'] == params[:client_secret]
      successful_oauth_response
    else
      error_oauth_response(ErrorResponseCodes::INVALID_CLIENT)
    end
  end
end
