# Windows Azure Active Directory Authentication Library (ADAL) for Ruby
[![Build Status](https://travis-ci.org/Azure/azure-activedirectory-library-for-ruby.png?branch=dev)](https://travis-ci.org/AzureAD/azure-activedirectory-library-for-ruby)

The ADAL for Ruby library makes it easy for Ruby applications to authenticate to AAD in order to access AAD protected web resources.

## Installation

You can install the ADAL gem with Rubygems.

```
gem install adal
```

Alternatively, you can build the gem from scratch.

```
git clone git@github.com:AzureAD/azure-activedirectory-for-ruby.git
cd azure-activedirectory-for-ruby
gem build adal.gemspec
gem install adal
```

## Samples

The `samples` folder contains several applications demonstrating different ways to authenticate. None of the samples will work out of the box, they require set-up and configuration through the Azure portal. Make sure to check out the README for each sample to get them running.

## How to run tests

The tests in this repo use the RSpec framework for behavior-driven testing. RSpec can be invoked directly or as a Rake task. The preferred way to execute the test suite is

Checkout the repo

`git clone git@github.com:AzureAD/azure-activedirectory-library-for-ruby`

Install the dependencies

`bundle install`

Run the tests

`bundle exec rake spec`

## How to run Rubocop

This gem abides by the [Rubocop](https://github.com/bbatsov/rubocop) defaults. Rubocop is set up as a Rake task. The preferred way to execute Rubocop for this repo is

Checkout the repo

`git clone git@github.com:AzureAD/azure-activedirectory-library-for-ruby`

Install the dependencies

`bundle install`

Run Rubocop

`bundle exec rake rubocop`

## Diagnostics

**Logs, correlation ids and timestamps are required with all requests for help in debugging.**

You can configure ADAL to generate log messages that you can use to help diagnose issues. The log outputs are standard to Ruby's built-in logger. An example ADAL log message looks like this:

```
I, [2015-08-18T06:58:12.767490 #9231]  INFO -- 969f3e30-8f42-4342-b135-f5c754a6b4a8: Multiple WS-Trust endpoints were found in the mex response. Only one was used.
```

The `I` is a shorthand for `INFO` that makes parsing logs easier. ADAL supports five different logging levels, `VERBOSE`, `INFO`, `WARN`, `ERROR` and `FATAL`. The timestamp is taken from the client machine. The GUID before the message is a correlation id that is used to track logs from the client to the server.


To set the lowest log level to output, include something like this in your configuration:

```
ADAL::Logging.log_level = ADAL::Logger::VERBOSE
```

By default, ADAL logs are printed to `STDOUT`. To change the log output, pass a Ruby `IO` object to ADAL like this in your configuration:

```
ADAL::Logging.log_output = File.open('/path/to/adal.logs', 'w')
```

## Community Help and Support

We leverage [Stack Overflow](http://stackoverflow.com/) to work with the community on supporting Azure Active Directory and its SDKs, including this one! We highly recommend you ask your questions on Stack Overflow (we're all on there!) Also browse existing issues to see if someone has had your question before.

We recommend you use the "adal" tag so we can see it! Here is the latest Q&A on Stack Overflow for ADAL: [http://stackoverflow.com/questions/tagged/adal](http://stackoverflow.com/questions/tagged/adal)

## Contributing

All code is licensed under the MIT license and we triage actively on GitHub. We enthusiastically welcome contributions and feedback. You can fork the repo and start contributing now. [More details](https://github.com/AzureAD/azure-activedirectory-library-for-ruby/blob/master/contributing.md) about contributing.


## License

Copyright (c) Microsoft Corporation. Licensed under the MIT License.
