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
