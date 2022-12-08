# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'lago/version'

Gem::Specification.new do |spec|
  spec.name = 'lago-ruby-client'
  spec.version = Lago::VERSION
  spec.authors = ['Lovro Colic']
  spec.email = ['lovro@getlago.com']

  spec.summary = 'Lago Rest API client'
  spec.homepage = 'https://github.com/getlago/lago-ruby-client'
  spec.license = 'AGPL-3.0'

  spec.metadata['homepage_uri'] = 'https://www.getlago.com/'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://doc.getlago.com'

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.files = `git ls-files lib`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency('jwt')
  spec.add_dependency('openssl')

  spec.add_development_dependency 'debug', '>= 1.0.0'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
  spec.add_development_dependency 'webmock'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
