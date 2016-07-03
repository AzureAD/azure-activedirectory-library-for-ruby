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

# All of the data that the fake token and authority endpoints support. It is
# separated into its own module so that it can be used as a mix-in in test
# classes.
module FakeData
  AUTH_CODE = 'auth_code_1'
  DEVICE_CODE = 'CA1BCDEF2'
  AUTHORITY = 'login.windows.net'
  ASSERTION = 'header.payload.crypto'
  CLIENT_ID = 'client_id_1'
  CLIENT_SECRET = 'client_secret_1'
  PASSWORD = 'password1'
  REDIRECT_URI = 'http://redirect1.com'
  REFRESH_TOKEN = 'refresh_token_1'
  RETURNED_TOKEN = 'a new token'
  RESOURCE = 'resource'
  TENANT = 'TENANT1'
  USERNAME = 'user1@TENANT1'
  USER_ASSERTION = 'user_assertion_1'
end
