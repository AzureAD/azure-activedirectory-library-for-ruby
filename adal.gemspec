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

require File.expand_path('../lib/adal/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'adal'
  s.version = ADAL::Version

  s.summary = 'ADAL for Ruby'
  s.description = 'Windows Azure Active Directory authentication client library'
  s.homepage = 'http://github.com/AzureAD/azure-activedirectory-library-for-ruby'
  s.license = 'MIT'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")

  s.author = 'Microsoft Corporation'
  s.email = 'nugetaad@microsoft.com'

  s.required_ruby_version = '>= 2.1.0'

  s.add_runtime_dependency 'jwt', '>= 1.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'uri_template', '~> 0.7'

  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.3'
  s.add_development_dependency 'rubocop', '~> 0.32'
  s.add_development_dependency 'simplecov', '~> 0.10'
  s.add_development_dependency 'sinatra', '~> 1.4'
  s.add_development_dependency 'webmock', '~> 1.21'
end
