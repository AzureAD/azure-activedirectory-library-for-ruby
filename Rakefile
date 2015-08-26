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

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# This can be run with `bundle exec rake spec`.
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = `git ls-files`.split("\n").select { |f| f.end_with? 'spec.rb' }
  t.rspec_opts = '--format documentation'
end

# This can be run with `bundle exec rake rubocop`.
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = `git ls-files`.split("\n").select { |f| f.end_with? '.rb' }
  t.fail_on_error = false
end

task default: :spec
