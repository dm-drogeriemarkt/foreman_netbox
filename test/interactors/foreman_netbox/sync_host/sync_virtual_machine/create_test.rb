# frozen_string_literal: true

require 'test_plugin_helper'

class CreateVirtualMachineTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::Create.call(
      host: host,
      virtual_machine: virtual_machine,
      cluster: cluster,
      tenant: tenant
    )
  end

  let(:host) do
    OpenStruct.new(
      name: 'host.dev.example.com',
      compute_object: OpenStruct.new(
        cpus: 2,
        memory_mb: 512,
        volumes: [
          OpenStruct.new(size_gb: 128)
        ]
      ),
      location: OpenStruct.new(
        name: 'Location'
      )
    )
  end
  let(:cluster) { OpenStruct.new(id: 1) }
  let(:tenant) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when virtual_machine is not assigned to the context' do
    let(:virtual_machine) { nil }

    it 'creates a virtual_machine' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines/").with(
        body: {
          name: host.name,
          cluster: cluster.id,
          tenant: tenant.id,
          vcpus: host.compute_object.cpus,
          memory: host.compute_object.memory_mb,
          disk: host.compute_object.volumes.map(&:size_gb).reduce(&:+)
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: 1, name: host.name }.to_json
      )

      assert_equal 1, subject.virtual_machine.id
      assert_requested(stub_post)
    end
  end

  context 'when virtual_machine is already assigned to the context' do
    let(:virtual_machine) { OpenStruct.new }

    it 'does not create a virtual_machine' do
      assert_equal virtual_machine, subject.virtual_machine
    end
  end
end
