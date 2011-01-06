# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hudson-to-pisswhistle}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Adam"]
  s.date = %q{2011-01-06}
  s.default_executable = %q{hudson-to-pisswhistle}
  s.email = %q{james@lazyatom.com}
  s.executables = ["hudson-to-pisswhistle"]
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "bin/hudson-to-pisswhistle", "lib/hudson_to_pisswhistle.rb"]
  s.homepage = %q{http://gofreerange.com}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Gathers build data from hudson and posts it to a URL}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<crack>, ["~> 0.1.8"])
      s.add_runtime_dependency(%q<json>, ["~> 1.4.6"])
      s.add_development_dependency(%q<kintama>, ["~> 0.1.1"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9"])
    else
      s.add_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_dependency(%q<crack>, ["~> 0.1.8"])
      s.add_dependency(%q<json>, ["~> 1.4.6"])
      s.add_dependency(%q<kintama>, ["~> 0.1.1"])
      s.add_dependency(%q<mocha>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<httparty>, ["~> 0.6.1"])
    s.add_dependency(%q<crack>, ["~> 0.1.8"])
    s.add_dependency(%q<json>, ["~> 1.4.6"])
    s.add_dependency(%q<kintama>, ["~> 0.1.1"])
    s.add_dependency(%q<mocha>, ["~> 0.9"])
  end
end
