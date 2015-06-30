# All of the data that the fake token and authority endpoints support. It is
# separated into its own module so that it can be used as a mix-in in test
# classes.
module FakeData
  AUTH_CODE = 'auth_code_1'
  AUTHORITY = 'login.windows.net'
  ASSERTION = 'header.payload.crypto'
  CLIENT_ID = 'client_id_1'
  CLIENT_SECRET = 'client_secret_1'
  REDIRECT_URI = 'http://redirect1.com'
  REFRESH_TOKEN = 'refresh_token_1'
  RESOURCE = 'resource'
  TENANT = 'TENANT1'
end
