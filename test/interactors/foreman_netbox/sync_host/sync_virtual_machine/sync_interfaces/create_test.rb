# frozen_string_literal: true

require 'test_plugin_helper'

class CreateVirtualMachineInterfacesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncInterfaces::Create.call(
      host: host, virtual_machine: virtual_machine, interfaces: interfaces
    )
  end

  let(:interfaces) { [OpenStruct.new(name: host.interfaces.second.name)] }
  let(:virtual_machine) { OpenStruct.new(id: 1) }
  let(:host) do
    OpenStruct.new(
      interfaces: [
        OpenStruct.new(name: 'INT1', mac: 'fe:13:c6:44:29:24'),
        OpenStruct.new(name: 'INT2', mac: 'fe:13:c6:44:29:22')
      ]
    )
  end

  setup do
    setup_default_netbox_settings
  end

  it 'creates missing interfaces' do
    interfaces.expects(:reload).once.returns(true)

    stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/virtualization/interfaces/").with(
      body: {
        virtual_machine: virtual_machine.id,
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
