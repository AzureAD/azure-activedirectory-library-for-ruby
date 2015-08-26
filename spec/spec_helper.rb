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

require_relative './support/fake_token_endpoint'

require 'simplecov'
require 'webmock/rspec'

# The coverage tool only considers code after this line.
SimpleCov.start do
  add_filter 'spec' # ignore spec files
end

require 'adal'

# Don't print any logs from ADAL::Logger.
ADAL::Logging.log_output = File.open(File::NULL, 'w')

# Unit tests do not need network access. Any attempts to access the network
# will throw exceptions.
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    # Any network requests matching these RegExps will be redirected to the mock
    # Sinatra servers in $DIR/spec/support. Any network requests that don't
    # match will attempt to access the network and raise exceptions.
    stub_request(:post, %r{oauth2/token}).to_rack(FakeTokenEndpoint)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
