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

# This web app demonstrates the authorization code flow of obtaining access
# tokens with ADAL.
#
# To run this web app, you need to:
# 1. Register a web application under your Azure Active Directory account.
# 2. Replace CLIENT_ID, CLIENT_SECRET and TENANT with your values.
# 3. Ensure that Ruby and Sinatra are installed on your system.
# 4. Install ADAL with `gem install adal`.
# 5. Start Sinatra with `ruby web_app.rb`.

require 'adal'
require 'json'
require 'net/http'
require 'securerandom'
require 'sinatra'
require 'uri'

AUTHORITY = 'login.windows.net'
CLIENT_ID = 'your_client_id_here'
CLIENT_SECRET = 'your_client_secret_here'
RESOURCE = 'https://graph.windows.net'
TENANT = 'your_tenant_here.onmicrosoft.com'

# AuthenticationContext is specific to a tenant. Our application only cares
# about one tenant, so we only need one AuthenticationContext.
auth_ctx = ADAL::AuthenticationContext.new(AUTHORITY, TENANT)

# ADAL::ClientCredential is one of several ways that you can identify your
# client application. It contains a client id and a client secret, which are
# assigned to you by Azure when you register your application.
client_cred = ADAL::ClientCredential.new(CLIENT_ID, CLIENT_SECRET)

# ADAL supports four logging options: VERBOSE, INFO, WARN and ERROR.
# They are defined as constants in ADAL::Logger and are used in ADAL::Logging,
# the mix-in factory module that provides Loggers to the various ADAL classes.
# By default, log_level = ADAL::Logger::ERROR so only error messages will be
# displayed.
ADAL::Logging.log_level = ADAL::Logger::VERBOSE

# ADAL allows you to redirect log outputs to a file or any Ruby object
# that implements IO. By default they are sent to STDOUT.
ADAL::Logging.log_output = 'my_adal_logs.log'

# This is Sinatra specific code that allows storing data as a browser cookie.
configure do
  enable :sessions
  set :session_secret, 'secret'
end

# Public landing page for the web app.
get '/' do
  'This is a public page. Anyone can see it.<br/>' \
  'If you have credentials, you can view the protected phone book ' \
  "for your organization <a href='/secure'>here</a>."
end

# In order to access /secure, the user needs an access token for the resource
# (https://graph.windows.net) that /secure will be displaying.
before '/secure' do
  redirect to('/auth') unless session[:access_token]
end

# Now that we have an access token, we use it to access the resource.
# The details here are specific to your resource.
get '/secure' do
  resource_uri = URI(RESOURCE + '/' + TENANT + '/users?api-version=2013-04-05')
  headers = { 'authorization' => session[:access_token] }
  http = Net::HTTP.new(resource_uri.hostname, resource_uri.port)
  http.use_ssl = true
  graph = JSON.parse(http.get(resource_uri, headers).body)

  # The resource is displayed to the user.
  'Here is your phone book.<br/><br/>' +
    graph['value'].map do |user|
      %(Given Name: #{user['givenName']}<br/>
        Surname: #{user['surname']}<br/>
        Address: #{user['streetAddress']}, #{user['city']}, #{user['country']}
        <br/><br/>)
    end.join(' ') +
    "You can log out <a href='/logout'>here</a>.<br/>" \
    "Or refresh the token <a href='/refresh'>here.</a>"
end

# Removes the access token from the session. The user will have to authenticate
# again if they wish to revisit their phone book.
get '/logout' do
  session.clear
  redirect to('/')
end

get '/auth' do
  # Request authorization by redirecting the user. ADAL will help create the
  # URL, but it will not make the actual request for you. In this case, the
  # request is made by Sinatra's redirect function.
  redirect auth_ctx.authorization_request_url(RESOURCE, CLIENT_ID, uri), 303
end

# The authorization code is returned from the authorization server as
# params[:code]. We pass this to ADAL to acquire an access_token.
post '/auth' do
  token_response = auth_ctx.acquire_token_with_authorization_code(
    params[:code], uri, client_cred, RESOURCE)
  case token_response
  when ADAL::SuccessResponse
    # ADAL successfully exchanged the authorization code for an access_token.
    # The token_response includes other information but we only care about the
    # access token and the refresh token.
    session[:access_token] = token_response.access_token
    session[:refresh_token] = token_response.refresh_token
    redirect to('/secure')
  when ADAL::ErrorResponse
    # ADAL failed to exchange the authorization code for an access_token.
    redirect to('/')
  end
end

before '/refresh' do
  redirect to('/auth') unless session[:refresh_token]
end

get '/refresh' do
  token_response = auth_ctx.acquire_token_with_refresh_token(
    session[:refresh_token], client_cred, RESOURCE)
  session[:access_token] = token_response.access_token
  session[:refresh_token] = token_response.refresh_token
  redirect to('/secure')
end
