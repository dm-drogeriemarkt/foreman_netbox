# frozen_string_literal: true

require 'test_plugin_helper'

class DeleteVirtualMachineIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::SyncIpAddresses::Delete.call(
      host: host, interfaces: interfaces, ip_addresses: ip_addresses, netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:interfaces) { ForemanNetbox::API.client.virtualization.interfaces.filter(virtual_machine_id: 1) }
  let(:ip_addresses) { ForemanNetbox::API.client.ipam.ip_addresses.filter(virtual_machine_id: 1) }

  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          ip: '10.0.0.1',
          subnet: FactoryBot.build_stubbed(:subnet_ipv4)
        )
      ]
    )
  end

  let(:interface_id) { 1 }
  let(:ip_addresses_v4_id) { 1 }
  let(:ip_addresses_v6_id) { 2 }
  let(:ip_addresses_v4) { host.interfaces.first.netbox_ip }
  let(:ip_addresses_v6) { '1500:0:2d0:201::1/32' }

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/interfaces.json").with(
      query: { limit: 50, virtual_machine_id: 1 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [
          { id: interface_id, name: host.interfaces.first.netbox_name }
        ]
      }.to_json
    )
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, virtual_machine_id: 1 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 2,
        results: [
          { id: ip_addresses_v4_id, address: ip_addresses_v4, assigned_object_type: 'virtualization.vminterface', assigned_object_id: interface_id },
          { id: ip_addresses_v6_id, address: ip_addresses_v6, assigned_object_type: 'virtualization.vminterface', assigned_object_id: interface_id }
        ]
      }.to_json
    )
  end

  it 'deletes from Netbox IP addresses that are not assigned to the host' do
    stub_delete_ip_address_v4 = stub_request(:delete, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/#{ip_addresses_v4_id}.json").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' }
    )
    stub_delete_ip_address_v6 = stub_request(:delete, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/#{ip_addresses_v6_id}.json").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' }
    )

    subject
    assert_not_requested(stub_delete_ip_address_v4)
    assert_requested(stub_delete_ip_address_v6)
  end
end
