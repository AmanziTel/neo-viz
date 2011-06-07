# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "neo-viz/version"

Gem::Specification.new do |s|
  s.name        = "neo-viz"
  s.version     = Neo::Viz::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Anders Janmyr"]
  s.email       = ["anders.janmyr@jayway.com"]
  s.homepage    = ""
  s.summary     = %q{A gem for visualizing a Neo database with Javascript}
  s.description = %q{A gem for visualizing a Neo database with Javascript}

  s.rubyforge_project = "neo-viz"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
