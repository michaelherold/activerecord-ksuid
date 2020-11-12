# frozen_string_literal: true

require File.expand_path(File.join('lib', 'active_record', 'ksuid', 'version'), __dir__)

Gem::Specification.new do |spec|
  spec.name    = 'activerecord-ksuid'
  spec.version = ActiveRecord::KSUID::VERSION
  spec.authors = ['Michael Herold']
  spec.email   = ['opensource@michaeljherold.com']

  spec.summary     = 'Adds support for K-Sortable Unique IDentifiers to ActiveRecord'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/michaelherold/activerecord-ksuid'
  spec.license     = 'MIT'

  spec.metadata['changelog_uri'] = 'https://github.com/michaelherold/activerecord-ksuid/blob/main/CHANGELOG.md'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = %w[CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md]
  spec.files += %w[ksuid.gemspec]
  spec.files += Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.0.0'
  spec.add_dependency 'ksuid'

  spec.add_development_dependency 'bundler', '>= 1.15'
end
