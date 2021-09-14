# frozen_string_literal: true

# This calls the main test_helper in Foreman-core
require 'test_helper'

ActiveSupport::TestCase.file_fixture_path = File.join(File.dirname(__FILE__), 'fixtures')

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def setup_default_netbox_settings(netbox_url: 'https://netbox.example.com', netbox_api_token: 'api_key')
  if Gem::Version.new(SETTINGS[:version].notag) < Gem::Version.new('2.6')
    FactoryBot.create(:setting, name: 'netbox_url', value: netbox_url, category: 'Setting::Netbox')
    FactoryBot.create(:setting, name: 'netbox_api_token', value: netbox_api_token, category: 'Setting::Netbox')
    FactoryBot.create(:setting, name: 'netbox_orchestration_enabled', value: true, category: 'Setting::Netbox')
  else
    Setting[:netbox_url] = netbox_url
    Setting[:netbox_api_token] = netbox_api_token
    Setting[:netbox_orchestration_enabled] = true
  end
end

def setup_netbox_integration_test
  skip unless ENV['FOREMAN_NETBOX_URL'] && ENV['FOREMAN_NETBOX_TOKEN']

  setup_default_netbox_settings(
    netbox_url: ENV['FOREMAN_NETBOX_URL'],
    netbox_api_token: ENV['FOREMAN_NETBOX_TOKEN']
  )
end

def default_tags
  ForemanNetbox::SyncHost::SyncTags::Organizer::DEFAULT_TAGS.map.with_index(1) do |tag, id|
    ForemanNetbox::API.client::Extras::Tag.new(id: id, name: tag[:name], slug: tag[:slug])
  end
end
