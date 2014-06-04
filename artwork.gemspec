# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'artwork/version'

Gem::Specification.new do |spec|
  spec.name          = 'artwork'
  spec.version       = Artwork::VERSION
  spec.authors       = ['Dimitar Dimitrov']
  spec.email         = ['dimitar@live.bg']
  spec.summary       = 'Automated image size scaling view helpers.'
  spec.description   = 'Works for any browser and uses cookies for transporting browser info to the backend.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'rails', '>= 2.3'
end
