require "bundler"
Bundler.setup

$:.unshift(File.expand_path("../lib", __FILE__))

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require(f) }
