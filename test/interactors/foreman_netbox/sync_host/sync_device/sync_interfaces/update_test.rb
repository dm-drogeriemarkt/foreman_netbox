# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateDeviceInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::Update.call(
      interfaces: interfaces,
      host: host,
      netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:interfaces) { ForemanNetbox::API.client::DCIM::Interfaces.new }
  let(:old_mac) { 'FE:13:C6:44:29:22' }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth1',
          mac: old_mac
        )
      ]
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'if the interface has been updated since the last synchronization' do
    let(:new_mac) { 'FE:13:C6:44:29:24' }

    it 'updats interface in Netbox' do
      get_stub = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/interfaces.json").with(
        query: { limit: 50 }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: host.interfaces.first.netbox_name,
              mac_address: new_mac,
              tags: []
            }
          ]
        }.to_json
      )
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/interfaces/1.json").with(
        body: {
          mac_address: host.interfaces.first.mac,
          tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS
        }.to_json
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      subject
      assert_requested(get_stub)
      assert_requested(stub_patch)
    end
  end

  context 'if the host has not been updated since the last synchronization' do
    it 'does not update interface on Netbox' do
      get_stub = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/interfaces.json").with(
        query: { limit: 50 }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: host.interfaces.first.netbox_name,
              mac_address: old_mac,
              tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS
            }
          ]
        }.to_json
      )

      subject
      assert_requested(get_stub)
    end
  end
end
