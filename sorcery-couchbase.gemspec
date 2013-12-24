# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sorcery_couchbase/version'

Gem::Specification.new do |spec|
  spec.name          = 'sorcery-couchbase'
  spec.version       = SorceryCouchbase::VERSION
  spec.authors       = ['Mike Evans']
  spec.email         = ['mike@urlgonomics.com']
  spec.description   = %q{Couchbase backend for Sorcery authentication framework}
  spec.summary       = %q{Couchbase backend for Sorcery authentication framework}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.platform      = 'java' if defined?(JRUBY_VERSION)

  spec.add_dependency 'sorcery'
  spec.add_dependency 'activemodel'
  if defined?(JRUBY_VERSION)
    spec.add_dependency 'couchbase-jruby-model', '>= 0.1.0'
  else
    spec.add_dependency 'couchbase-model', '>= 0.5.3'
  end

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '>= 5.0'
  spec.add_development_dependency 'pry'
end
