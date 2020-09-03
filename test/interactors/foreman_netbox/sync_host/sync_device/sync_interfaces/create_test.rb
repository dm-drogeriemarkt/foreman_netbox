# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::Create.call(
      host: host, netbox_params: host.netbox_facet.netbox_params, device: device, interfaces: interfaces
    )
  end

  let(:interfaces) { [OpenStruct.new(name: host.interfaces.second.netbox_name)] }
  let(:device) { OpenStruct.new(id: 1) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      interfaces: [
        FactoryBot.build_stubbed(:nic_base, mac: 'FE:13:C6:44:29:24', ip: '10.0.0.1', ip6: '1500:0:2d0:201::1'),
        FactoryBot.build_stubbed(:nic_base, mac: 'FE:13:C6:44:29:22', ip: '10.0.0.2', ip6: '1500:0:2d0:201::2'),
        FactoryBot.build_stubbed(:nic_base, identifier: nil, mac: nil)
      ]
    )
  end

  setup do
    setup_default_netbox_settings
  end

  it 'creates missing interfaces' do
    interfaces.expects(:reload).once.returns(true)

    stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/interfaces/").with(
      body: {
        name: host.interfaces.first.netbox_name,
        mac_address: host.interfaces.first.mac,
        tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS,
        type: ForemanNetbox::NetboxParameters::DEFAULT_INTERFACE_TYPE,
        device: device.id
      }.to_json
    ).to_return(
      status: 201, headers: { 'Content-Type': 'application/json' },
      body: {
        id: 1,
        name: host.interfaces.first.netbox_name
      }.to_json
    )

    subject
    assert_requested(stub_post)
  end
end
