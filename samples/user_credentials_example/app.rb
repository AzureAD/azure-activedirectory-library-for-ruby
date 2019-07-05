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

# This will make ADAL log the various steps of obtaining an access token.
ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
CLIENT_ID = 'your clientid here'
RESOURCE = 'https://graph.windows.net'
TENANT = 'your tenant here'
CLIENT_SECURET = 'your clientsecret here'

def prompt(*args)
  print(*args)
  gets.strip
end

username = prompt 'Username: '
password = prompt 'Password: '

user_cred = ADAL::UserCredential.new(username, password)
ctx = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT)
result = ctx.acquire_token_for_user(RESOURCE, CLIENT_ID, user_cred, { ADAL::RequestParameters::CLIENT_SECRET => CLIENT_SECURET })

case result
when ADAL::SuccessResponse
  puts 'Successfully authenticated with user credentials. Received access ' \
       "token: #{result.access_token}."
when ADAL::FailureResponse
  puts 'Failed to authenticate with client credentials. Received error: ' \
       "#{result.error} and error description: #{result.error_description}."
end
