$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dynabute/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dynabute"
  s.version     = Dynabute::VERSION
  s.authors     = ["Liooo"]
  s.email       = ["ryoyamada3@gmail.com"]
  s.homepage    = "https://github.com/Liooo/dynabute"
  s.summary     = "DYNAmic attriBUTEs for ActiveRecord"
  s.description = "Dynamically add attributes on ActiveRecord."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_runtime_dependency 'activerecord', ['>= 4.2.8']

  s.add_development_dependency "rails", '~> 5'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec-rails", '~> 5'
end
