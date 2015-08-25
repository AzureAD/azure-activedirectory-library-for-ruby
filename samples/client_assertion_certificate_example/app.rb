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
