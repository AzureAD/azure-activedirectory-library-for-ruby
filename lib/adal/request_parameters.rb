module ADAL
  # Names of parameters in OAuth requests. This module can be included in any
  # class to reference the parameters instead of referring to them as strings
  # or symbols
  module RequestParameters
    AAD_API_VERSION = 'api-version'.to_sym
    ASSERTION = 'assertion'.to_sym
    CLIENT_ASSERTION = 'client_assertion'.to_sym
    CLIENT_ASSERTION_TYPE = 'client_assertion_type'.to_sym
    CLIENT_ID = 'client_id'.to_sym
    CLIENT_REQUEST_ID = 'client-request-id'.to_sym
    CLIENT_RETURN_CLIENT_REQUEST_ID = 'client-return-client-request-id'.to_sym
    CLIENT_SECRET = 'client_secret'.to_sym
    CODE = 'code'.to_sym
    FORM_POST = 'form_post'.to_sym
    GRANT_TYPE = 'grant_type'.to_sym
    PASSWORD = 'password'.to_sym
    REDIRECT_URI = 'redirect_uri'.to_sym
    REFRESH_TOKEN = 'refresh_token'.to_sym
    RESOURCE = 'resource'.to_sym
    SCOPE = 'scope'.to_sym
    USER_ID = 'user_id'.to_sym
    USERNAME = 'username'.to_sym
  end
end
