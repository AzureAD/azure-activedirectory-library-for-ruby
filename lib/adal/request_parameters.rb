module ADAL
  # Names of parameters in OAuth requests. This module can be included in any
  # class to reference the parameters instead of referring to them as strings
  # or symbols
  module RequestParameters
    GRANT_TYPE = 'grant_type'
    CLIENT_ASSERTION = 'client_assertion'
    CLIENT_ID = 'client_id'
    CLIENT_SECRET = 'client_secret'
    REDIRECT_URI = 'redirect_uri'
    RESOURCE = 'resource'
    CODE = 'code'
    SCOPE = 'scope'
    ASSERTION = 'assertion'
    AAD_API_VERSION = 'api-version'
    USERNAME = 'username'
    PASSWORD = 'password'
    REFRESH_TOKEN = 'refresh_token'
  end
end
