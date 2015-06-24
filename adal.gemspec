Gem::Specification.new do |s|
  s.name = 'adal'
  s.version = '0.0.0'

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
end
