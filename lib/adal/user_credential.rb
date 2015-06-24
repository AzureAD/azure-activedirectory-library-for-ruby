module ADAL
  # A convenience class for username and password credentials.
  class UserCredential
    attr_reader :username
    attr_reader :password

    def initialize(username, password)
      @username = username
      @password = password
    end
  end
end
