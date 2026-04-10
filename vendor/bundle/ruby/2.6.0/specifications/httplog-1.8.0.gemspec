# -*- encoding: utf-8 -*-
# stub: httplog 1.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "httplog".freeze
  s.version = "1.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/trusche/httplog/issues", "changelog_uri" => "https://github.com/trusche/httplog/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/trusche/httplog" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thilo Rusche".freeze]
  s.date = "1980-01-02"
  s.description = "Log outgoing HTTP requests made from your application. Helpful for tracking API calls\n                     of third party gems that don't provide their own log output.".freeze
  s.email = "thilorusche@gmail.com".freeze
  s.homepage = "http://github.com/trusche/httplog".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.0.3.1".freeze
  s.summary = "Log outgoing HTTP requests.".freeze

  s.installed_by_version = "3.0.3.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<ethon>.freeze, ["~> 0.11"])
      s.add_development_dependency(%q<excon>.freeze, ["~> 0.60"])
      s.add_development_dependency(%q<faraday>.freeze, [">= 1.3"])
      s.add_development_dependency(%q<faraday-multipart>.freeze, [">= 1.0"])
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_development_dependency(%q<http>.freeze, [">= 4.0"])
      s.add_development_dependency(%q<httparty>.freeze, ["~> 0.16"])
      s.add_development_dependency(%q<httpclient>.freeze, ["~> 2.8"])
      s.add_development_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<typhoeus>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<listen>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<patron>.freeze, ["~> 0.12"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.15"])
      s.add_development_dependency(%q<thin>.freeze, [">= 1.7"])
      s.add_development_dependency(%q<oj>.freeze, [">= 3.9.2"])
      s.add_development_dependency(%q<csv>.freeze, [">= 0"])
      s.add_development_dependency(%q<logger>.freeze, [">= 0"])
      s.add_development_dependency(%q<ostruct>.freeze, [">= 0"])
      s.add_development_dependency(%q<base64>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<rack>.freeze, [">= 2.0"])
      s.add_runtime_dependency(%q<rainbow>.freeze, [">= 2.0.0"])
      s.add_runtime_dependency(%q<benchmark>.freeze, [">= 0"])
    else
      s.add_dependency(%q<ethon>.freeze, ["~> 0.11"])
      s.add_dependency(%q<excon>.freeze, ["~> 0.60"])
      s.add_dependency(%q<faraday>.freeze, [">= 1.3"])
      s.add_dependency(%q<faraday-multipart>.freeze, [">= 1.0"])
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_dependency(%q<http>.freeze, [">= 4.0"])
      s.add_dependency(%q<httparty>.freeze, ["~> 0.16"])
      s.add_dependency(%q<httpclient>.freeze, ["~> 2.8"])
      s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_dependency(%q<typhoeus>.freeze, ["~> 1.4"])
      s.add_dependency(%q<listen>.freeze, ["~> 3.0"])
      s.add_dependency(%q<patron>.freeze, ["~> 0.12"])
      s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.15"])
      s.add_dependency(%q<thin>.freeze, [">= 1.7"])
      s.add_dependency(%q<oj>.freeze, [">= 3.9.2"])
      s.add_dependency(%q<csv>.freeze, [">= 0"])
      s.add_dependency(%q<logger>.freeze, [">= 0"])
      s.add_dependency(%q<ostruct>.freeze, [">= 0"])
      s.add_dependency(%q<base64>.freeze, [">= 0"])
      s.add_dependency(%q<rack>.freeze, [">= 2.0"])
      s.add_dependency(%q<rainbow>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<benchmark>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<ethon>.freeze, ["~> 0.11"])
    s.add_dependency(%q<excon>.freeze, ["~> 0.60"])
    s.add_dependency(%q<faraday>.freeze, [">= 1.3"])
    s.add_dependency(%q<faraday-multipart>.freeze, [">= 1.0"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
    s.add_dependency(%q<http>.freeze, [">= 4.0"])
    s.add_dependency(%q<httparty>.freeze, ["~> 0.16"])
    s.add_dependency(%q<httpclient>.freeze, ["~> 2.8"])
    s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
    s.add_dependency(%q<typhoeus>.freeze, ["~> 1.4"])
    s.add_dependency(%q<listen>.freeze, ["~> 3.0"])
    s.add_dependency(%q<patron>.freeze, ["~> 0.12"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.15"])
    s.add_dependency(%q<thin>.freeze, [">= 1.7"])
    s.add_dependency(%q<oj>.freeze, [">= 3.9.2"])
    s.add_dependency(%q<csv>.freeze, [">= 0"])
    s.add_dependency(%q<logger>.freeze, [">= 0"])
    s.add_dependency(%q<ostruct>.freeze, [">= 0"])
    s.add_dependency(%q<base64>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, [">= 2.0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<benchmark>.freeze, [">= 0"])
  end
end
