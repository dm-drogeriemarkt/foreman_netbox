# frozen_string_literal: true

require 'test_plugin_helper'

class FindVirtualMachineTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::Find.call(
      host: host,
      netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(:host).tap do |host|
      host.stubs(:compute?).returns(true)
      host.stubs(:mac).returns('C3:CD:63:54:21:62')
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when virtual machine already exists in Netbox' do
    test 'find virtual_machine by host name' do
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_name = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 1, results: [{ id: 1, name: host.name }] }.to_json
      )

      assert_equal 1, subject.virtual_machine.id
      assert_requested(stub_get_by_mac_addres)
      assert_requested(stub_get_by_name)
    end

    test 'find virtual_machine by mac address' do
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 1, results: [{ id: 1, name: host.name }] }.to_json
      )

      assert_equal 1, subject.virtual_machine.id
      assert_requested(stub_get_by_mac_addres)
    end
  end

  context 'when virtual machine does not exist in Netbox' do
    it 'does not assign virtual_machine to context' do
      stub_get_by_mac_addres = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, mac_address: host.mac }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )
      stub_get_by_name = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { count: 0, results: [] }.to_json
      )

      assert_nil subject.virtual_machine
      assert_requested(stub_get_by_mac_addres)
      assert_requested(stub_get_by_name)
    end
  end
end
