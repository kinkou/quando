# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quando/version'

Gem::Specification.new do |spec|
  spec.name          = 'quando'
  spec.version       = Quando::VERSION
  spec.authors       = ['Sergey Konotopov']
  spec.email         = ['werk@mail.ru']

  spec.summary       = %q{Highly configurable text date parser.}
  spec.description   = %q{Define your own patterns and parse those dates you want, how you want.}
  spec.homepage      = 'https://github.com/kinkou/quando'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
