require_relative './support/fake_auth_endpoint'
require_relative './support/fake_token_endpoint'

require 'simplecov'
require 'webmock/rspec'

# The coverage tool only considers code after this line.
SimpleCov.start do
  add_filter 'spec' # ignore spec files
end

require 'adal'

# Don't print any logs from ADAL::Logger.
ADAL::Logging.log_output = '/dev/null'

# Unit tests do not need network access. Any attempts to access the network
# will throw exceptions.
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    # Any network requests matching these RegExps will be redirected to the mock
    # Sinatra servers in $DIR/spec/support. Any network requests that don't
    # match will attempt to access the network and raise exceptions.
    stub_request(:post, %r{oauth2/authorize}).to_rack(FakeAuthEndpoint)
    stub_request(:post, %r{oauth2/token}).to_rack(FakeTokenEndpoint)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
