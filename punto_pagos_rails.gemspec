$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "punto_pagos_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "punto_pagos_rails"
  s.version     = PuntoPagosRails::VERSION
  s.authors     = ["Leandro Segovia"]
  s.email       = ["ldlsegovia@gmail.com"]
  s.homepage    = ""
  s.summary     = "Rails engine to manager transactions using acidlabs's puntopagos-ruby gem"
  s.description = "Rails engine to manager transactions using acidlabs's puntopagos-ruby gem"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency "puntopagos", "0.2.3"
  s.add_dependency "enumerize", "0.8.0"

  s.add_development_dependency "sqlite3"
end
