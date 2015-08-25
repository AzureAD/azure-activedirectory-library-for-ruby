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
  # WSTrust namespaces for the username/password OAuth flow as well as action
  # constants and maps to go between bindings, actions and namespaces.
  module XmlNamespaces
    NAMESPACES = {
      'a' => 'http://www.w3.org/2005/08/addressing',
      'o' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
      's' => 'http://www.w3.org/2003/05/soap-envelope',
      'u' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
      'wsa' => 'http://www.w3.org/2005/08/addressing',
      'wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
      'wsp' => 'http://schemas.xmlsoap.org/ws/2004/09/policy',
      'soap12' => 'http://schemas.xmlsoap.org/wsdl/soap12/',
      'sp' => 'http://schemas.xmlsoap.org/ws/2005/07/securitypolicy',
      'ssp' => 'http://docs.oasis-open.org/ws-sx/ws-securitypolicy/200702'
    }

    NAMESPACES_2005 =
      NAMESPACES.merge(
        'trust' => 'http://schemas.xmlsoap.org/ws/2005/02/trust')

    NAMESPACES_13 =
      NAMESPACES.merge(
        'trust' => 'http://docs.oasis-open.org/ws-sx/ws-trust/200512')

    WSTRUST_2005 = 'http://schemas.xmlsoap.org/ws/2005/02/trust/RSTR/Issue'
    WSTRUST_13 = 'http://docs.oasis-open.org/ws-sx/ws-trust/200512/RSTRC/IssueFinal'

    ACTION_TO_NAMESPACE = { WSTRUST_13 => NAMESPACES_13,
                            WSTRUST_2005 => NAMESPACES_2005 }

    BINDING_TO_ACTION = {
      'UserNameWSTrustBinding_IWSTrustFeb2005Async' => WSTRUST_2005,
      'UserNameWSTrustBinding_IWSTrustFeb2005Async1' => WSTRUST_2005,
      'UserNameWSTrustBinding_IWSTrust13Async' => WSTRUST_13,
      'UserNameWSTrustBinding_IWSTrust13Async1' => WSTRUST_13
    }
  end
end
