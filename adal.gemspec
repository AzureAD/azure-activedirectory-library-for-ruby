# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adal/version'

Gem::Specification.new do |s|
  s.name = 'adal'
  s.version = ADAL::VERSION

  s.summary = 'ADAL for Ruby'
  s.description = 'Windows Azure Active Directory authentication client library'
  s.homepage = 'http://github.com/AzureAD/azure-activedirectory-library-for-ruby'
  s.license = 'Apache 2.0'

  s.require_paths = ['lib']
  s.files += Dir['lib/*.rb']
  s.files += Dir['lib/adal/*.rb']

  s.author = 'Microsoft Open Technologies Inc'
  s.homepage = 'https://msopentech.com'
  s.email = 'msopentech@microsoft.com'

  s.add_development_dependency 'bundler', '~> 1.10'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.2'
end
