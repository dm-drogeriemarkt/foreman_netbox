# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateVirtualMachineInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::Update.call(
      interfaces: interfaces,
      host: host,
      netbox_params: host.netbox_facet.netbox_params,
      tags: default_tags
    )
  end

  let(:interfaces) { ForemanNetbox::API.client::Virtualization::Interfaces.new }
  let(:old_mac) { 'FE:13:C6:44:29:22' }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(:nic_base, mac: old_mac)
      ]
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'if the interface has been updated since the last synchronization' do
    let(:new_mac) { 'FE:13:C6:44:29:24' }

    it 'updates interface in Netbox' do
      get_stub = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/interfaces.json").with(
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
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/interfaces/1.json").with(
        body: {
          mac_address: host.interfaces.first.mac.upcase,
          tags: default_tags.map(&:id)
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

  context 'if the interface has not been updated since the last synchronization' do
    it 'does not update interface on Netbox' do
      get_stub = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/interfaces.json").with(
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
              tags: default_tags.map do |tag|
                { id: tag.id }
              end
            }
          ]
        }.to_json
      )
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/interfaces/1.json")

      subject
      assert_requested(get_stub)
      assert_not_requested(stub_patch)
    end
  end
end
