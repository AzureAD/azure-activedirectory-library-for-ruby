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

## Community Help and Support

We leverage [Stack Overflow](http://stackoverflow.com/) to work with the community on supporting Azure Active Directory and its SDKs, including this one! We highly recommend you ask your questions on Stack Overflow (we're all on there!) Also browser existing issues to see if someone has had your question before.

We recommend you use the "adal" tag so we can see it! Here is the latest Q&A on Stack Overflow for ADAL: [http://stackoverflow.com/questions/tagged/adal](http://stackoverflow.com/questions/tagged/adal)

## Contributing

All code is licensed under the Apache 2.0 license and we triage actively on GitHub. We enthusiastically welcome contributions and feedback. You can fork the repo and start contributing now.


## License

Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved. Licensed under the Apache License, Version 2.0 (the "License"); 
