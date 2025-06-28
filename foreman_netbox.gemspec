# frozen_string_literal: true

require File.expand_path('lib/foreman_netbox/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_netbox'
  s.version     = ForemanNetbox::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['dmTECH GmbH']
  s.email       = ['opensource@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt/foreman_netbox'
  s.summary     = 'Adds integration with NetBox'

  s.required_ruby_version = '>= 2.7', '< 4'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'dry-validation', '~> 1.8.1'
  s.add_dependency 'interactor', '~> 3.1.1'
  s.add_dependency 'netbox-client-ruby', '~> 0.6.0'

  # pin versions
  s.add_dependency 'dry-container', '0.9.0'
  s.add_dependency 'dry-core', '0.9.1'
  s.add_dependency 'dry-schema', '1.10.6'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'theforeman-rubocop', '~> 0.1.2'
end
