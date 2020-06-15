# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::Find.call(host: host) }

  let(:host) do
    FactoryBot.build_stubbed(:host).tap do |host|
      host.stubs(:mac).returns('C3:CD:63:54:21:62')
      host.stubs(:facts).returns({ serialnumber: 'abc123' })
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when device already exists in Netbox' do
    test 'find device by host name' do
      stub_get_by_serial = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, serial: host.facts[:serialnumber] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_name = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 1, results: [{ id: 1, name: host.name }] }.to_json
      )

      assert_equal 1, subject.device.id
      assert_requested(stub_get_by_serial)
      assert_requested(stub_get_by_mac_addres)
      assert_requested(stub_get_by_name)
    end

    test 'find device by mac address' do
      stub_get_by_serial = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, serial: host.facts[:serialnumber] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 1, results: [{ id: 1, name: host.name }] }.to_json
      )

      assert_equal 1, subject.device.id
      assert_requested(stub_get_by_serial)
      assert_requested(stub_get_by_mac_addres)
    end

    test 'find device by serial number' do
      stub_get_by_serial = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, serial: host.facts[:serialnumber] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 1, results: [{ id: 1, name: host.name }] }.to_json
      )

      assert_equal 1, subject.device.id
      assert_requested(stub_get_by_serial)
    end
  end

  context 'when device does not exist in NetBox' do
    it 'does not assign device to context' do
      stub_get_by_serial = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, serial: host.facts[:serialnumber] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_name = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/devices.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )

      assert_nil subject.site
      assert_requested(stub_get_by_serial)
      assert_requested(stub_get_by_mac_addres)
      assert_requested(stub_get_by_name)
    end
  end
end
