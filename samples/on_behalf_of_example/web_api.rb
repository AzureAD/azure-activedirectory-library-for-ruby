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
