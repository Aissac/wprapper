# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wprapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'wprapper'
  spec.version       = Wprapper::VERSION
  spec.authors       = ['Mihai Bobina', 'Istvan Hoka']
  spec.email         = ['mihai@frombase.com', 'istvan.hoka@gmail.com']
  spec.summary       = 'Manage wordpress entities'
  spec.description   = 'Wordpress wrapper for posts'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'hashie'
  spec.add_dependency 'rubypress'
  spec.add_dependency 'rest-client'

  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'multi_json'
end
