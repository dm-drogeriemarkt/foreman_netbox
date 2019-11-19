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

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'netbox-client-ruby', '~> 0.5.1'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rubocop'
end
