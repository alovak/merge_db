# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "merge_db/version"

Gem::Specification.new do |s|
  s.name        = "merge_db"
  s.version     = MergeDb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pavel Gabriel"]
  s.email       = ["alovak@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Merge your Rails databases}
  s.description = %q{With merge db you can easily merge your databases and save all associations}

  s.rubyforge_project = "merge_db"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-cucumber"
  s.add_development_dependency "ruby-debug19"

  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "mysql2"
  s.add_runtime_dependency "ruby-progressbar"
end
