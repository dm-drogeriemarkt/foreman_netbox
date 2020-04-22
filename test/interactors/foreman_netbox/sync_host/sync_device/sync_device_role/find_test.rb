# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceRoleTest < ActiveSupport::TestCase
  let(:klass) { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceRole::Find }
  let(:device_role_params) { klass.new }

  subject { klass.call }

  setup do
    setup_default_netbox_settings
  end

  context 'when device_role exists in Netbox' do
    it 'assigns device_role to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/device-roles.json").with(
        query: { limit: 50, slug: device_role_params.slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: device_role_params.name,
              slug: device_role_params.slug
            }
          ]
        }.to_json
      )

      assert_equal 1, subject.device_role.id
      assert_requested(stub_get)
    end
  end

  context 'when device_role does not exist in NetBox' do
    it 'does not assign device_role to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/device-roles.json").with(
        query: { limit: 50, slug: device_role_params.slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.device_role
      assert_requested(stub_get)
    end
  end
end
