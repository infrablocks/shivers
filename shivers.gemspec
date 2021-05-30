# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shivers/version'

Gem::Specification.new do |spec|
  spec.name = 'shivers'
  spec.version = Shivers::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.date = '2021-01-11'
  spec.summary = 'Semantic version numbers for CI pipelines.'
  spec.description = 'Semantic version number management, by file and environment, for CI pipelines.'
  spec.homepage = 'https://github.com/infrablocks/shivers'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(bin|lib|CODE_OF_CONDUCT\.md|shivers\.gemspec|Gemfile|LICENSE\.txt|Rakefile|README\.md)})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'semantic', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake_circle_ci', '~> 0.9'
  spec.add_development_dependency 'rake_github', '~> 0.7'
  spec.add_development_dependency 'rake_ssh', '~> 0.6'
  spec.add_development_dependency 'rake_gpg', '~> 0.14'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'fakefs', '~> 0.18'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
