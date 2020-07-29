lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quando/version'

Gem::Specification.new do |spec|
  spec.name          = 'quando'
  spec.version       = Quando::VERSION
  spec.authors       = ['Sergey Konotopov']
  spec.email         = ['werk@mail.ru']

  spec.summary       = %q{Configurable date parser}
  spec.description   = %q{Parse dates in any language and format by setting your own recognition patterns}
  spec.homepage      = 'https://github.com/kinkou/quando'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '>= 1.15'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'pry'
end
