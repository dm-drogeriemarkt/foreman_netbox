# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::SyncIpAddresses::Create.call(
      host: host,
      interfaces: interfaces,
      netbox_params: host.netbox_facet.netbox_params,
      tags: default_tags
    )
  end

  let(:interfaces) { [OpenStruct.new(id: 1, name: host.interfaces.first.netbox_name)] }
  let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4) }
  let(:subnet6) { FactoryBot.build_stubbed(:subnet_ipv6) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          mac: 'FE:13:C6:44:29:24',
          ip: '10.0.0.1',
          ip6: '1500:0:2d0:201::1',
          subnet: subnet,
          subnet6: subnet6
        )
      ]
    )
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, interface_id: interfaces.first.id, address: host.interfaces.first.netbox_ip }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 0,
        results: []
      }.to_json
    )
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, interface_id: interfaces.first.id, address: host.interfaces.first.netbox_ip6 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [{ id: 2 }]
      }.to_json
    )
  end

  it 'creates missing IP addresses in Netbox' do
    stub_post_ip_address_v4 = stub_request(:post, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/").with(
      body: {
        address: host.interfaces.first.netbox_ip,
        assigned_object_type: 'dcim.interface',
        assigned_object_id: interfaces.first.id,
        tags: default_tags.map(&:id)
      }.to_json
    ).to_return(
      status: 201, headers: { 'Content-Type': 'application/json' },
      body: { id: 1 }.to_json
    )

    stub_post_ip_address_v6 = stub_request(:post, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/").with(
      body: {
        address: host.interfaces.first.netbox_ip6,
        assigned_object_type: 'dcim.interface',
        assigned_object_id: interfaces.first.id,
        tags: default_tags.map(&:id)
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
