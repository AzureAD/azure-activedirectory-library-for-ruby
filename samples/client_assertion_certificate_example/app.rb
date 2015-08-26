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

# See the accompanying README.md for instructions on how to set-up an
# application to run this sample.

require 'adal'
require 'openssl'

# This will make ADAL log the various steps of JWT creation from certificates.
ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
CLIENT_ID = 'your client id here'
RESOURCE = 'https://outlook.office365.com'
TENANT = 'your tenant here.onmicrosoft.com'

PFX_PATH = './path/to/your/cert.pfx'
PFX_PASSWORD = 'password'

pfx = OpenSSL::PKCS12.new(File.read(PFX_PATH), PFX_PASSWORD)

authority = ADAL::Authority.new(AUTHORITY_HOST, TENANT)
client_cred = ADAL::ClientAssertionCertificate.new(authority, CLIENT_ID, pfx)
result = ADAL::AuthenticationContext
         .new(AUTHORITY_HOST, TENANT)
         .acquire_token_for_client(RESOURCE, client_cred)

case result
when ADAL::SuccessResponse
  puts 'Successfully authenticated with client credentials. Received access ' \
       "token: #{result.access_token}."
when ADAL::FailureResponse
  puts 'Failed to authenticate with client credentials. Received error: ' \
       "#{result.error} and error description: #{result.error_description}."
end
