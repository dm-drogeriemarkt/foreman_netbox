# frozen_string_literal: true

require 'test_plugin_helper'

class DeleteVirtualMachineIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::SyncIpAddresses::Delete.call(
      host: host, interfaces: interfaces, ip_addresses: ip_addresses
    )
  end

  let(:interfaces) { ForemanNetbox::API.client::Virtualization::Interfaces.new }
  let(:ip_addresses) { ForemanNetbox::API.client::IPAM::IpAddresses.new }
  let(:host) do
    OpenStruct.new(
      interfaces: [
        OpenStruct.new(
          name: 'INT1',
          subnet: OpenStruct.new(network_address: ip_addresses_v4)
        )
      ]
    )
  end

  let(:interface_id) { 1 }
  let(:ip_addresses_v4_id) { 1 }
  let(:ip_addresses_v6_id) { 2 }
  let(:ip_addresses_v4) { '10.0.0.1/24' }
  let(:ip_addresses_v6) { '1500:0:2d0:201::1/32' }

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/interfaces.json").with(
      query: { limit: 50 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [
          { id: interface_id, name: host.interfaces.first.name }
        ]
      }.to_json
    )
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 2,
        results: [
          { id: ip_addresses_v4_id, address: ip_addresses_v4, interface: { id: interface_id } },
          { id: ip_addresses_v6_id, address: ip_addresses_v6, interface: { id: interface_id } }
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
