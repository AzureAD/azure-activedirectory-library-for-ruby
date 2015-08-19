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

require File.expand_path('../lib/adal/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'adal'
  s.version = ADAL::Version

  s.summary = 'ADAL for Ruby'
  s.description = 'Windows Azure Active Directory authentication client library'
  s.homepage = 'http://github.com/AzureAD/azure-activedirectory-library-for-ruby'
  s.license = 'Apache 2.0'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")

  s.author = 'Microsoft Open Technologies Inc'
  s.homepage = 'https://msopentech.com'
  s.email = 'msopentech@microsoft.com'

  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'jwt', '~> 1.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'uri_template', '~> 0.7'

  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.3'
  s.add_development_dependency 'rubocop', '~> 0.32'
  s.add_development_dependency 'simplecov', '~> 0.10'
  s.add_development_dependency 'sinatra', '~> 1.4'
  s.add_development_dependency 'webmock', '~> 1.21'
end
