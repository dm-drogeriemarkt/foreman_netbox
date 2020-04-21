# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::Find.call(host: host) }

  let(:host) { OpenStruct.new(name: 'host.dev.example.com') }

  setup do
    setup_default_netbox_settings
  end

  context 'when device exists in Netbox' do
    it 'assigns device to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [{ id: 1, name: host.name }]
        }.to_json
      )

      assert_equal 1, subject.device.id
      assert_requested(stub_get)
    end
  end

  context 'when device does not exist in NetBox' do
    it 'does not assign device to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.site
      assert_requested(stub_get)
    end
  end
end
