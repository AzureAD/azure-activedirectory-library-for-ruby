source "https://rubygems.org"

gem 'jwt'
gem 'openssl'
gem 'uri_template'

group :test do
  gem 'rspec'

  # Measures test coverages.
  gem 'simplecov', require: false

  # Used to mock a token endpoint.
  gem 'sinatra'

  # Used to reroute OAuth requests to the mock token endpoint.
  gem 'webmock'
end
