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

# All of the data that the fake token and authority endpoints support. It is
# separated into its own module so that it can be used as a mix-in in test
# classes.
module FakeData
  AUTH_CODE = 'auth_code_1'
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
