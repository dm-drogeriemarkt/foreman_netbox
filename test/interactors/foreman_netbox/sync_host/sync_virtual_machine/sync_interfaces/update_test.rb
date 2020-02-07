# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateVirtualMachineInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::Update.call(
      interfaces: interfaces,
      host: host
    )
  end

  let(:interfaces) { NetboxClientRuby::Virtualization::Interfaces.new }
  let(:old_mac) { 'fe:13:c6:44:29:22' }
  let(:host) do
    OpenStruct.new(
      interfaces: [
        OpenStruct.new(
          name: 'INT1',
          mac: old_mac
        )
      ]
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'if the interface has been updated since the last synchronization' do
    let(:new_mac) { 'fe:13:c6:44:29:24' }

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
              name: 'INT1',
              mac_address: new_mac
            }
          ]
        }.to_json
      )
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/interfaces/1.json").with(
        body: {
          mac_address: host.interfaces.first.mac
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
              name: 'INT1',
              mac_address: old_mac
            }
          ]
        }.to_json
      )

      subject
      assert_requested(get_stub)
    end
  end
end
