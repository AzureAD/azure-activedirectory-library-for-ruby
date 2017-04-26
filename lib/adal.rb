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
	autoload :AuthenticationContext,		'adal/authentication_context'
	autoload :AuthenticationParameters,		'adal/authentication_parameters'
	autoload :Authority,				'adal/authority'
	autoload :CacheDriver,				'adal/cache_driver'
	autoload :CachedTokenResponse,			'adal/cached_token_response'
	autoload :ClientAssertion,			'adal/client_assertion'
	autoload :ClientAssertionCertificate,		'adal/client_assertion_certificate'
	autoload :ClientCredential,			'adal/client_credential'
	autoload :CoreExt,				'adal/core_ext/hash'
	autoload :JwtParameters,			'adal/jwt_parameters'
	autoload :ADLogger,				'adal/logger'
	autoload :Logging,				'adal/logging'
	autoload :MemoryCache,				'adal/memory_cache'
	autoload :MexRequest,				'adal/mex_request'
	autoload :MexResponse,				'adal/mex_response'
	autoload :NoopCache,				'adal/noop_cache'
	autoload :OAuthRequest,				'adal/oauth_request'
	autoload :RequestParameters,			'adal/request_parameters'
	autoload :SelfSignedJwtFactory,			'adal/self_signed_jwt_factory'
	autoload :TokenRequest,				'adal/token_request'
	autoload :TokenResponse,			'adal/token_response'
	autoload :UserAssertion,			'adal/user_assertion'
	autoload :UserCredential,			'adal/user_credential'
	autoload :UserIdentifier,			'adal/user_identifier'
	autoload :UserInformation,			'adal/user_information'
	autoload :Util,					'adal/util'
	autoload :Version,				'adal/version'
	autoload :WSTrustRequest,			'adal/wstrust_request'
	autoload :WSTrustResponse,			'adal/wstrust_response'
	autoload :XmlNamespaces,			'adal/xml_namespaces'
end
