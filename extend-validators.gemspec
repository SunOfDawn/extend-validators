$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "extend-validators/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "extend-validators"
  s.version     = ExtendValidators::VERSION
  s.authors     = ["SunOfDawn"]
  s.email       = ["z707170821zz@gmail.com"]
  s.homepage    = "https://github.com/SunOfDawn/extend-validators"
  s.summary     = "some expansions for activemodel validation."
  s.description = "some expansions for activemodel validation."
  s.license     = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/*"]

  s.add_dependency 'activemodel', '~> 4.2.0'

  s.add_development_dependency 'rspec', '~> 2.13.0'
end
