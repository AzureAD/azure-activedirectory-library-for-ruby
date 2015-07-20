require_relative '../../lib/adal'

# This will make ADAL log the various steps of obtaining an access token.
ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
CLIENT_ID = 'your clientid here'
RESOURCE = 'https://graph.windows.net'
TENANT = 'your tenant here.onmicrosoft.com'

def prompt(*args)
  print(*args)
  gets.strip
end

username = prompt 'Username: '
password = prompt 'Password: '

user_cred = ADAL::UserCredential.new(username, password)
ctx = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT)
result = ctx.acquire_token_with_user_credential(RESOURCE, CLIENT_ID, user_cred)

case result
when ADAL::SuccessResponse
  puts 'Successfully authenticated with user credentials. Received access ' \
       "token: #{result.access_token}."
when ADAL::FailureResponse
  puts 'Failed to authenticate with client credentials. Received error: ' \
       "#{result.error} and error description: #{result.error_description}."
end
