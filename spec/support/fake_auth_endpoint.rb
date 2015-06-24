require 'sinatra/base'

# An endpoint server that uses FakeData to respond to requests.
class FakeAuthEndpoint < Sinatra::Base
  include FakeData

  get '/oauth2/authorize' do
    fail NotImplementedError
  end
end
