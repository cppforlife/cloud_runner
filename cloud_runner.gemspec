# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloud_runner/version"

Gem::Specification.new do |s|
  s.name        = "cloud_runner"
  s.version     = CloudRunner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dmitriy Kalinin", "Alex Suraci"]
  s.email       = ["cppforlife@gmail.com"]
  s.homepage    = "http://github.com/cppforlife/cloud_runner"
  s.summary     = %q{Quickly spin up new VM in the cloud to run a script.}
  s.description = %q{Currently only supports DigitalOcean.}

  s.rubyforge_project = "cloud_runner"

  s.add_dependency "digital_ocean"
  s.add_dependency "net-ssh"
  s.add_dependency "net-scp"

  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
