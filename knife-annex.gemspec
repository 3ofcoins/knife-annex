# -*- mode: ruby; coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-annex/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-annex"
  spec.version       = KnifeAnnex::VERSION
  spec.authors       = ["Maciej Pasternacki"]
  spec.email         = ["maciej@3ofcoins.net"]
  spec.description   = 'Knife plugin implementing a git-annex backend in chef-vault'
  spec.summary       = 'Knife plugin implementing a git-annex backend in chef-vault'
  spec.homepage      = "https://github.com/3ofcoins/knife-annex/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'chef-vault', '~> 2.2.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "thor", "~> 0.18.1"
end
