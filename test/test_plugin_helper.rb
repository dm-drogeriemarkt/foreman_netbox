# frozen_string_literal: true

# This calls the main test_helper in Foreman-core
require 'test_helper'

# require 'yaml'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'vcr_cassettes')
  c.hook_into :webmock
end

ActiveSupport::TestCase.file_fixture_path = File.join(File.dirname(__FILE__), 'fixtures')

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def setup_default_netbox_settings(netbox_url: 'https://netbox.example.com', netbox_api_token: 'api_key')
  FactoryBot.create(:setting, name: 'netbox_url', value: netbox_url, category: 'Setting::Netbox')
  FactoryBot.create(:setting, name: 'netbox_api_token', value: netbox_api_token, category: 'Setting::Netbox')
end

def setup_netbox_integration_test
  file = begin
    file_path = File.join(File.dirname(__FILE__), '..', 'config', 'netbox_integration_tests.yml')
    File.read(file_path)
  end
  config = YAML.safe_load(file)
  setup_default_netbox_settings(
    netbox_url: config.fetch('netbox_url'),
    netbox_api_token: config.fetch('netbox_api_token')
  )
end
