# frozen_string_literal: true

require 'test_plugin_helper'

class DeleteDeviceInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::Delete.call(
      host: host,
      netbox_params: host.netbox_facet.netbox_params,
      interfaces: interfaces
    )
  end

  let(:interface_id) { 1 }
  let(:interfaces) { ForemanNetbox::Api.client::DCIM::Interfaces.new }
  let(:host) do
    FactoryBot.build_stubbed(:host, interfaces: [])
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/interfaces/").with(
      query: { limit: 50 }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: [{ id: interface_id, name: 'eth0' }],
      }.to_json
    )
  end

  it 'deletes interfaces that are not assigned to the host' do
    stub_delete = stub_request(:delete, "#{Setting[:netbox_url]}/api/dcim/interfaces/#{interface_id}/").to_return(
      status: 200
    )

    subject
    assert_requested(stub_delete)
  end
end
