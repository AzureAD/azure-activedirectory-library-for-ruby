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

require 'nokogiri'
require 'uri'

module ADAL
  # WSTrust namespaces for the username/password OAuth flow.
  module XmlNamespaces
    NAMESPACES = {
      'a' => 'http://www.w3.org/2005/08/addressing',
      'http' => 'http://schemas.microsoft.com/ws/06/2004/policy/http',
      'q' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
      's' => 'http://www.w3.org/2003/05/soap-envelope',
      'soap12' => 'http://schemas.xmlsoap.org/wsdl/soap12/',
      'sp' => 'http://docs.oasis-open.org/ws-sx/ws-securitypolicy/200702',
      'sp2005' => 'http://schemas.xmlsoap.org/ws/2005/07/securitypolicy',
      'wsa' => 'http://www.w3.org/2005/08/addressing',
      'wsa10' => 'http://www.w3.org/2005/08/addressing',
      'wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
      'wsp' => 'http://schemas.xmlsoap.org/ws/2004/09/policy',
      'wst' => 'http://docs.oasis-open.org/ws-sx/ws-trust/200512',
      'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
      'trust' => 'http://docs.oasis-open.org/ws-sx/ws-trust/200512'
    }
  end
end
