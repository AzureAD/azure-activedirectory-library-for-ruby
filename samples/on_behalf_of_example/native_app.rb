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

token_response =
  ctx.acquire_token_for_user(WEB_API_RESOURCE, CLIENT_ID, user_cred)

web_api_uri = URI(WEB_API_ENDPOINT)
headers = { 'Bearer' => token_response.access_token }
http = Net::HTTP.new(web_api_uri.hostname, web_api_uri.port)
web_api_response = http.get(web_api_uri, headers)

puts 'Here is your directory user graph:'
puts JSON.pretty_generate(JSON.parse(web_api_response.body))
