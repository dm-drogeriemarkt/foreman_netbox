# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateVirtualMachineIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::SyncIpAddresses::Update.call(
      ip_addresses: ip_addresses,
      netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:ip_addresses) { ForemanNetbox::API.client.ipam.ip_addresses.filter(virtual_machine_id: 1) }
  let(:ip_addresses_data) do
    [
      { id: 1, address: host.netbox_facet.netbox_params[:ip_addresses].first[:address], tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS },
      { id: 2, address: host.netbox_facet.netbox_params[:ip_addresses].second[:address], tags: [] }
    ]
  end
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth0',
          ip: '10.0.0.7',
          ip6: '1600:0:2d0:202::17',
          subnet: FactoryBot.build_stubbed(:subnet_ipv4, organizations: [], locations: []),
          subnet6: FactoryBot.build_stubbed(:subnet_ipv6, organizations: [], locations: [])
        )
      ]
    )
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, virtual_machine_id: 1 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: ip_addresses_data.count,
        results: ip_addresses_data
      }.to_json
    )
  end

  test 'update ip addresses' do
    stub_unexpected_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/#{ip_addresses_data.first[:id]}.json")
    stub_expected_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/ipam/ip-addresses/#{ip_addresses_data.second[:id]}.json").with(
      body: {
        tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS
      }.to_json
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: { id: 2 }.to_json
    )

    assert subject.success?
    assert_not_requested stub_unexpected_patch
    assert_requested stub_expected_patch
  end
end
