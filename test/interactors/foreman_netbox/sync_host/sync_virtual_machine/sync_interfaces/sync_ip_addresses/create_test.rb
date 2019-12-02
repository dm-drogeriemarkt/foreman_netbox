# frozen_string_literal: true

require 'test_plugin_helper'

class CreateVirtualMachineIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::SyncIpAddresses::Create.call(
      host: host, interfaces: interfaces
    )
  end

  let(:interfaces) { [OpenStruct.new(id: 1, name: 'INT1')] }
  let(:host) do
    OpenStruct.new(
      interfaces: [
        OpenStruct.new(
          name: 'INT1',
          mac: 'fe:13:c6:44:29:24',
          subnet: OpenStruct.new(network_address: '10.0.0.1/24'),
          subnet6: OpenStruct.new(network_address: '1500:0:2d0:201::1/32')
        )
      ]
    )
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/ipam/ip-addresses.json").with(
      query: { limit: 50, interface_id: interfaces.first.id, address: host.interfaces.first.subnet.network_address }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 0,
        results: []
      }.to_json
    )
    stub_request(:get, "#{Setting[:netbox_url]}/ipam/ip-addresses.json").with(
      query: { limit: 50, interface_id: interfaces.first.id, address: host.interfaces.first.subnet6.network_address }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [{ id: 2 }]
      }.to_json
    )
  end

  it 'creates missing IP addresses in Netbox' do
    stub_post_ip_address_v4 = stub_request(:post, "#{Setting[:netbox_url]}/ipam/ip-addresses/").with(
      body: {
        interface: interfaces.first.id,
        address: host.interfaces.first.subnet.network_address
      }.to_json
    ).to_return(
      status: 201, headers: { 'Content-Type': 'application/json' },
      body: { id: 1 }.to_json
    )

    stub_post_ip_address_v6 = stub_request(:post, "#{Setting[:netbox_url]}/ipam/ip-addresses/").with(
      body: {
        interface: interfaces.first.id,
        address: host.interfaces.first.subnet6.network_address
      }.to_json
    ).to_return(
      status: 201, headers: { 'Content-Type': 'application/json' },
      body: { id: 1 }.to_json
    )

    subject
    assert_requested(stub_post_ip_address_v4)
    assert_not_requested(stub_post_ip_address_v6)
  end
end
