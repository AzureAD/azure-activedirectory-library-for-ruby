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

require_relative '../../lib/adal'
require 'sinatra'

# Uncomment this if you want to trace ADAL's execution.
# ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
TENANT = 'your tenant here.onmicrosoft.com'
RESOURCE = 'https://graph.windows.net'
CLIENT_ID = 'your client id here'
CLIENT_SECRET = 'your client secret here'

set :client_cred, ADAL::ClientCredential.new(CLIENT_ID, CLIENT_SECRET)
set :ctx, ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT)
set :port, 44_321

before do
  # If the client does not send an access token, then he is unauthorized.
  halt 401 unless env['HTTP_BEARER']

  token = exchange_tokens(env['HTTP_BEARER'])
  env[:access_token] = token.access_token

  # If we cannot exchange the clients access token for a new one, then he is
  # unauthorized.
  halt 401 unless env[:access_token]
end

# Fetches the contents of the /users graph endpoint.
get '/api/graph' do
  graph_uri = URI(RESOURCE + '/' + TENANT + '/users?api-version=2013-04-05')
  headers = { 'authorization' => env[:access_token] }
  http = Net::HTTP.new(graph_uri.hostname, graph_uri.port)
  http.use_ssl = true
  http.get(graph_uri, headers).body
end

##
# Exchanges an access token for this web api for an access token for another
# resource.
#
# @param String access_token
#   The token for this web service, from the client.
# @return String
#   An access token for the designated resource.
def exchange_tokens(access_token)
  settings.ctx.acquire_token_for_user(
    RESOURCE, settings.client_cred, ADAL::UserAssertion.new(access_token))
end
