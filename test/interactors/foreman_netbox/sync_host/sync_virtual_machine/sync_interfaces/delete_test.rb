# frozen_string_literal: true

require 'test_plugin_helper'

class DeleteVirtualMachineInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::Delete.call(
      host: host, netbox_params: host.netbox_facet.netbox_params, interfaces: interfaces
    )
  end

  let(:interface_id) { 1 }
  let(:interfaces) { ForemanNetbox::API.client::Virtualization::Interfaces.new }
  let(:host) { FactoryBot.build_stubbed(:host, interfaces: []) }

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/interfaces.json").with(
      query: { limit: 50 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [{ id: interface_id, name: 'eth0' }]
      }.to_json
    )
  end

  it 'deletes interface that is not assigned to the host' do
    stub_delete = stub_request(:delete, "#{Setting[:netbox_url]}/api/virtualization/interfaces/#{interface_id}.json").to_return(
      status: 200
    )

    subject
    assert_requested(stub_delete)
  end
end
