# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "preload_counts/version"

Gem::Specification.new do |s|
  s.name        = "preload_counts"
  s.version     = PreloadCounts::VERSION
  s.authors     = ["Simon Mathieu"]
  s.email       = ["simon.math@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Preload association or scope counts.}
  s.description = %q{Preload association or scope counts. This can greatly reduce the number of queries you have to perform and thus yield great performance gains.}

  s.rubyforge_project = "preload_counts"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rails", "~> 2.3.12"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "multi_rails"
end
