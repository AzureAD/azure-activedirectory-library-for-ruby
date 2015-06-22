require 'sinatra/base'

# TODO(aj-michael) Document this.
class FakeAuthEndpoint < Sinatra::Base
  get '/oauth2/authorize' do
    fail NotImplementedError
  end
end
