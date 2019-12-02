# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::Find.call(
      device: device
    )
  end

  let(:device) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when interfaces were found on Netbox' do
    it 'assigns interfaces to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/interfaces.json").with(
        query: { limit: 50, device_id: device.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: 'INT1'
            }
          ]
        }.to_json
      )

      assert_equal [1], subject.interfaces.map(&:id)
      assert_requested(stub_get)
    end
  end

  context 'when interfaces were not found on Netbox' do
    it 'does not assign interfaces to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/interfaces.json").with(
        query: { limit: 50, device_id: device.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_equal [], subject.interfaces.map(&:id)
      assert_requested(stub_get)
    end
  end
end
