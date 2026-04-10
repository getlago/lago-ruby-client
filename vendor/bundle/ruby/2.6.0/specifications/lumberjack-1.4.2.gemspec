# -*- encoding: utf-8 -*-
# stub: lumberjack 1.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "lumberjack".freeze
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/bdurand/lumberjack/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/bdurand/lumberjack", "source_code_uri" => "https://github.com/bdurand/lumberjack" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brian Durand".freeze]
  s.date = "2025-09-12"
  s.email = ["bbdurand@gmail.com".freeze]
  s.homepage = "https://github.com/bdurand/lumberjack".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.0.3.1".freeze
  s.summary = "A simple, powerful, and fast logging utility with excellent structured logging support that can be a drop in replacement for the standard library Logger.".freeze

  s.installed_by_version = "3.0.3.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
