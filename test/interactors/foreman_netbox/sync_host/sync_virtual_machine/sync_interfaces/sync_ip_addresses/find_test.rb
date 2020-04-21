# frozen_string_literal: true

require 'test_plugin_helper'

class FindVirtualMachineIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::SyncIpAddresses::Find.call(
      virtual_machine: virtual_machine
    )
  end

  let(:virtual_machine) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when ip_addresses were found on Netbox' do
    it 'assigns ip_addresses to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
        query: { limit: 50, virtual_machine_id: virtual_machine.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [{ id: 1 }]
        }.to_json
      )

      assert_equal [1], subject.ip_addresses.map(&:id)
      assert_requested(stub_get)
    end
  end

  context 'when ip_addresses were not found on Netbox' do
    it 'does not assign ip_addresses to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
        query: { limit: 50, virtual_machine_id: virtual_machine.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_equal [], subject.ip_addresses.map(&:id)
      assert_requested(stub_get)
    end
  end
end
