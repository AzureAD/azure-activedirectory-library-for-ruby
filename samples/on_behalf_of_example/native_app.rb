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
require 'json'

def prompt(*args)
  print(*args)
  gets.strip
end

# Uncomment this if you want to trace ADAL's execution.
# ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
TENANT = 'your tenant here.onmicrosoft.com'
CLIENT_ID = 'your client id here'
WEB_API_RESOURCE = 'https://your tenant here.onmicrosoft.com/MyWebService'
WEB_API_ENDPOINT = 'http://localhost:44321/api/graph'

user_cred = ADAL::UserCredential.new(prompt('Username: '), prompt('Password: '))
ctx = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT)

token_response = ctx.acquire_token_with_user_credential(
  WEB_API_RESOURCE, CLIENT_ID, user_cred)

web_api_uri = URI(WEB_API_ENDPOINT)
headers = { 'Bearer' => token_response.access_token }
http = Net::HTTP.new(web_api_uri.hostname, web_api_uri.port)
web_api_response = http.get(web_api_uri, headers)

puts 'Here is your directory user graph:'
puts JSON.pretty_generate(JSON.parse(web_api_response.body))
