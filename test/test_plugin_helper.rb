# frozen_string_literal: true

# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def setup_default_netbox_settings
  FactoryBot.create(:setting, name: 'netbox_url', value: 'https://netbox.example.com/api', category: 'Setting::Netbox')
  FactoryBot.create(:setting, name: 'netbox_api_key', value: 'api_key', category: 'Setting::Netbox')
end
