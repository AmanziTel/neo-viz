# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "neo_viz/version"

Gem::Specification.new do |s|
  s.name        = "neo-viz"
  s.version     = NeoViz::VERSION
  s.authors     = ["Anders Janmyr"]
  s.email       = ["anders.janmyr@jayway.com"]
  s.homepage    = ""
  s.summary     = %q{A gem for visualizing a Neo database with Javascript}
  s.description = %q{A gem for visualizing a Neo database with Javascript}

  s.rubyforge_project = "neo-viz"

  s.add_dependency 'sinatra'
  s.add_dependency 'sinatra-reloader'
  s.add_dependency 'neo4j', '~> 1.1'
  s.add_dependency 'coffee-script'
  s.add_dependency 'therubyracer'
  s.add_dependency 'haml'
  s.add_dependency 'sass'
  s.add_dependency 'json'
  

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'jasmine'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
