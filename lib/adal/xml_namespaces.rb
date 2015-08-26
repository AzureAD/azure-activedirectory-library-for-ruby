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
