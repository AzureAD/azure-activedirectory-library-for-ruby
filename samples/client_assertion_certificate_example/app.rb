# See the accompanying README.md for instructions on how to set-up an
# application to run this sample.

require_relative '../../lib/adal'

require 'openssl'

# This will make ADAL log the various steps of JWT creation from certificates.
ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
CLIENT_ID = 'your client id here'
RESOURCE = 'https://outlook.office365.com'
TENANT = 'your tenant here.onmicrosoft.com'

# The path to your public certificate.
CERT_PATH = './path/to/your/public/cert.pem'

# The path to you private key file.
KEY_PATH = './path/to/your/private/key.pem'

# The password to your private key file, or the empty string if there is none.
KEY_PASSWORD = 'password'

cert = OpenSSL::X509::Certificate.new(File.read(CERT_PATH))
key = OpenSSL::PKey::RSA.new(File.read(KEY_PATH), 'password')

authority = ADAL::Authority.new(AUTHORITY_HOST, TENANT)
client_cred = ADAL::ClientAssertionCertificate
              .new(authority, CLIENT_ID, cert, key)
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
