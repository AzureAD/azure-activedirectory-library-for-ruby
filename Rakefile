require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = `git ls-files`.split("\n").select { |f| f.end_with? 'spec.rb' }
  t.rspec_opts = '--format documentation'
end
task default: :spec
