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
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2", ">= 4.2.0"
  s.add_dependency "aasm", "~> 4.0", ">= 4.0.4"
  s.add_dependency "enumerize", "~> 1.1", ">= 1.1.1"

  s.add_development_dependency "rspec-rails", "~> 3.4.0"
  s.add_development_dependency "pry-rails", "0.3.2"
  s.add_development_dependency "factory_girl_rails", "~> 4.6.0"
  s.add_development_dependency "shoulda-matchers", "2.6.1"
  s.add_development_dependency "guard", "~> 2.7.0"
  s.add_development_dependency "guard-rspec", "~> 4.3"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "coveralls"
end
