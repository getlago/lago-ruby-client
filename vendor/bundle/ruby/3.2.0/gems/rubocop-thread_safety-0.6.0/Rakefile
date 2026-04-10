# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'open3'
require 'rspec/core/rake_task'

Dir['tasks/**/*.rake'].each { |t| load t }

RSpec::Core::RakeTask.new(:spec)

desc 'Confirm documentation is up to date'
task confirm_documentation: :generate_cops_documentation do
  _, _, _, process =
    Open3.popen3('git diff --exit-code docs/')

  unless process.value.success?
    abort 'Please run `rake generate_cops_documentation` ' \
          'and add docs/ to the commit.'
  end
end

task default: :spec
