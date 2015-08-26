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
    UNIQUE_ID = 'unique_id'.to_sym
    USER_INFO = 'user_info'.to_sym
    USERNAME = 'username'.to_sym
  end
end
