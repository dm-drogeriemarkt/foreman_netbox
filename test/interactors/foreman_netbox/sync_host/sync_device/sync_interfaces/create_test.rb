# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::Create.call(
      host: host, device: device, interfaces: interfaces
    )
  end

  let(:interfaces) { [OpenStruct.new(name: host.interfaces.second.name)] }
  let(:device) { OpenStruct.new(id: 1) }
  let(:host) do
    OpenStruct.new(
      interfaces: [
        OpenStruct.new(
          name: 'INT1',
          mac: 'fe:13:c6:44:29:24',
          subnet: OpenStruct.new(network_address: '10.0.0.1/24'),
          subnet6: OpenStruct.new(network_address: '1500:0:2d0:201::1/32')
        ),
        OpenStruct.new(
          name: 'INT2',
          mac: 'fe:13:c6:44:29:22',
          subnet: OpenStruct.new(network_address: '10.0.0.2/24'),
          subnet6: OpenStruct.new(network_address: '1500:0:2d0:201::2/32')
        )
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
        device: device.id,
        name: host.interfaces.first.name,
        mac_address: host.interfaces.first.mac
      }.to_json
    ).to_return(
      status: 201, headers: { 'Content-Type': 'application/json' },
      body: {
        id: 1,
        name: host.interfaces.first.name
      }.to_json
    )

    subject
    assert_requested(stub_post)
  end
end
