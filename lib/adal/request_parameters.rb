module ADAL
  # Names of parameters in OAuth requests. This module can be included in any
  # class to reference the parameters instead of referring to them as strings
  # or symbols
  module RequestParameters
    AAD_API_VERSION = 'api-version'
    ASSERTION = 'assertion'
    CLIENT_ASSERTION = 'client_assertion'
    CLIENT_ID = 'client_id'
    CLIENT_REQUEST_ID = 'client-request-id'
    CLIENT_RETURN_CLIENT_REQUEST_ID = 'client-return-client-request-id'
    CLIENT_SECRET = 'client_secret'
    CODE = 'code'
    FORM_POST = 'form_post'
    GRANT_TYPE = 'grant_type'
    PASSWORD = 'password'
    REDIRECT_URI = 'redirect_uri'
    REFRESH_TOKEN = 'refresh_token'
    RESOURCE = 'resource'
    SCOPE = 'scope'
    USERNAME = 'username'
  end
end
