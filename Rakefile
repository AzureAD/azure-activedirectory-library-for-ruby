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

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# This can be run with `bundle exec rake spec`.
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = `git ls-files`.split("\n").select { |f| f.end_with? 'spec.rb' }
  t.rspec_opts = '--format documentation'
end

# This can be run with `bundle exec rake rubocop`.
RuboCop::RakeTask.new

task default: :spec
