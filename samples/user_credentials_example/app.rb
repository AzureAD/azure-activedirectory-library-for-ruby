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

require 'adal'

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
