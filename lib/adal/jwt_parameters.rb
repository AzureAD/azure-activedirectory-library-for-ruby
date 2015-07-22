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

module ADAL
  # Literals used in JWT header and payload.
  module JwtParameters
    ALGORITHM = 'alg'
    AUDIENCE = 'aud'
    EXPIRES_ON = 'exp'
    ISSUER = 'iss'
    JWT_ID = 'jti'
    NOT_BEFORE = 'nbf'
    RS256 = 'RS256'
    SELF_SIGNED_JWT_LIFETIME = 10
    SUBJECT = 'sub'
    THUMBPRINT = 'x5t'
    TYPE = 'typ'
    TYPE_JWT = 'JWT'
  end
end
