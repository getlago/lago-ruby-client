# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  directories %w[lib spec]

  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/lago/api/resources/(.+)\.rb$}) do |m|
    [
      "spec/lago/api/resources/#{m[1]}_spec.rb",
      "spec/integration/#{m[1]}s_spec.rb",
    ]
  end
end
