$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "atila/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "atila"
  s.version     = Atila::VERSION
  s.authors     = ["Josue Quintana & Isaac Jarquin"]
  s.email       = 'josukintana@gmail.com'
  s.homepage    = "https://github.com/josukintana/atila.git"
  s.summary     = "Social gem"
  s.description = "This is a social gem"

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
end
