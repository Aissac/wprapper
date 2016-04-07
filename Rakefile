ENV['gem_push'] = 'false'

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task '.env' => '.env.sample' do
  cp '.env.sample', '.env'
end

task :default => :spec
