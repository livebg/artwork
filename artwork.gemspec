# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'artwork/version'

Gem::Specification.new do |spec|
  spec.name          = 'artwork'
  spec.version       = Artwork::VERSION
  spec.authors       = ['Dimitar Dimitrov']
  spec.email         = ['dimitar@live.bg']
  spec.summary       = 'Automated user resolution based image size choosing for Rails.'
  spec.description   = 'Automated user resolution based image size choosing for your Rails views, but done at the backend.'
  spec.homepage      = 'https://github.com/mitio/artwork'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'paperclip', '>= 2.3'
  spec.add_development_dependency 'sqlite3'

  spec.add_dependency 'rails', '>= 2.3'
  spec.add_dependency 'uglifier'
end
