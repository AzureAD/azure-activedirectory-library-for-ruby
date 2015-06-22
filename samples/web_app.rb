# This web app demonstrates the authorization code flow of obtaining access
# tokens with ADAL.
#
# To run this web app, you need to:
# 1. Register a web application under your Azure Active Directory account.
# 2. Replace CLIENT_ID, CLIENT_SECRET and TENANT with your values.
# 3. Ensure that Ruby and Sinatra are installed on your system.
# 4. Install ADAL with `gem install adal`.
# 5. Start Sinatra with `ruby web_app.rb`.

require_relative '../lib/adal'
require 'json'
require 'net/http'
require 'securerandom'
require 'sinatra'
require 'uri'

AUTHORITY = 'login.windows.net'
CLIENT_ID = 'd0644584-61de-4bca-98ab-e75af0ff5528'
CLIENT_SECRET = 'La55NMCC2ouDu3grNO5/wlCjE7qmAV0YnJFFIOYVU6U='
RESOURCE = 'https://graph.windows.net'
SITE_ID = 500_879
TENANT = 'adamajmichael.onmicrosoft.com'

# AuthenticationContext is specific to a tenant. Our application only cares
# about one tenant, so we only need one AuthenticationContext.
auth_ctx = ADAL::AuthenticationContext.new(AUTHORITY, TENANT)

configure do
  enable :sessions
  set :session_secret, 'secret'
end

# Landing page for the web app.
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
  # Request authorization by redirecting the user.
  redirect authorization_endpoint.to_s, 303
end

# The authorization code is obtained from the authorization server without ADAL.
def authorization_endpoint
  path = '/' + TENANT + '/oauth2/authorize'
  query = URI.encode_www_form(response_type: 'code id_token',
                              scope: 'openid',
                              response_mode: 'form_post',
                              redirect_uri: uri,
                              client_id: CLIENT_ID,
                              resource: RESOURCE,
                              nonce: SecureRandom.uuid,
                              site_id: SITE_ID)
  URI::HTTPS.build(host: AUTHORITY, path: path, query: query)
end

# The authorization code is returned from the authorization server as
# params[:code]. We pass this to ADAL to acquire an access_token.
post '/auth' do
  token_response = auth_ctx.acquire_token_with_authorization_code(
    RESOURCE, CLIENT_ID, CLIENT_SECRET, params[:code], uri)
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
    RESOURCE, CLIENT_ID, CLIENT_SECRET, uri, session[:refresh_token])
  session[:access_token] = token_response.access_token
  session[:refresh_token] = token_response.refresh_token
  redirect to('/secure')
end
