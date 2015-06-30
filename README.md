# Windows Azure Active Directory Authentication Library (ADAL) for Ruby
The ADAL for Ruby library makes it easy for Ruby applications to authenticate to AAD in order to access AAD protected web resources. It supports three authentication modes shown in the quickstart code below.


# Installing Dependencies
The ADAL dependencies are listed in `Gemfile` and can be installed with Bundler with the command `bundle install`.


# Running Tests
The gem uses RSpec for testing and SimpleCov for measuring test coverage. If you have RSpec installed already, you can run `rspec` from the root of the repository and it will generate a coverage report in `$DIR/coverage`. Alternatively, the test suite is set up as a rake task. At the moment there is only one testing task and it can be executed withe command `bundle exec rake spec`.
