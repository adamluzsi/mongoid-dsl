# coding: utf-8

Gem::Specification.new do |spec|

  spec.name          = "mongoid-dsl"
  spec.version       = File.open(File.join(File.dirname(__FILE__),"VERSION")).read.split("\n")[0].chomp.gsub(' ','')
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]
  spec.description   = "Ruby Module for ease of use with mongoid based models. with this module you get additional tools for your mongoid ODM. You can query directly to an embedded document class or getting references or parents for the model. Check Git for more!"
  spec.summary       = "Ruby Module for ease of use mongoid models"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_dependency "procemon", ">= 2.0.0"
  spec.add_dependency "mongoid",  ">= 3.1.0"
  spec.add_dependency "mpatch",   ">= 2.9.0"

end
