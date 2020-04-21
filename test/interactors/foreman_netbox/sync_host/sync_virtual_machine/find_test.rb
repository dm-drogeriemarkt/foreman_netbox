# frozen_string_literal: true

require 'test_plugin_helper'

class FindVirtualMachineTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncVirtualMachine::Find.call(host: host) }
  let(:host) { OpenStruct.new(name: 'host.development.example.com') }

  setup do
    setup_default_netbox_settings
  end

  context 'when virtual machine exists in Netbox' do
    it 'assigns virtual_machine to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: host.name
            }
          ]
        }.to_json
      )

      assert_equal 1, subject.virtual_machine.id
      assert_requested(stub_get)
    end
  end

  context 'when virtual machine does not exist in Netbox' do
    it 'does not assign virtual_machine to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines.json").with(
        query: { limit: 50, name: host.name }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.virtual_machine
      assert_requested(stub_get)
    end
  end
end
