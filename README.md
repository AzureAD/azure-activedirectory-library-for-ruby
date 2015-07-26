# Windows Azure Active Directory Authentication Library (ADAL) for Ruby
The ADAL for Ruby library makes it easy for Ruby applications to authenticate to AAD in order to access AAD protected web resources.

## Installation
ADAL for Ruby will be released on https://rubygems.org. Once that happens, you will be able to install the current version with

```
gem install adal
```

Currently, you can build the gem from scratch.

```
gem build adal.gemspec
gem install adal
```

## Tests
To run the tests, you first need to install the dependencies with `bundle install`. The tests are set up as a rake task, so they can be run with `bundle exec rake spec`.
