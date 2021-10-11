# frozen_string_literal: true

require 'test_plugin_helper'

class CreateVirtualMachineTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::Create.call(
      host: host,
      netbox_params: host.netbox_facet.netbox_params,
      virtual_machine: virtual_machine,
      cluster: cluster,
      tenant: tenant,
      tags: default_tags
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      hostname: 'host.dev.example.com',
      location: FactoryBot.build_stubbed(:location)
    ).tap do |host|
      host.stubs(:compute?).returns(true)
      host.stubs(:compute_object).returns(
        OpenStruct.new(
          cpus: 2,
          memory_mb: 512,
          volumes: [
            OpenStruct.new(size_gb: 128)
          ]
        )
      )
    end
  end

  let(:cluster) { OpenStruct.new(id: 1) }
  let(:tenant) { OpenStruct.new(id: 1) }
  let(:netbox_virtual_machine_params) { host.netbox_facet.netbox_params.fetch(:virtual_machine) }

  setup do
    setup_default_netbox_settings
  end

  context 'when virtual_machine is not assigned to the context' do
    let(:virtual_machine) { nil }

    it 'creates a virtual_machine' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines/").with(
        body: {
          vcpus: netbox_virtual_machine_params[:vcpus],
          memory: netbox_virtual_machine_params[:memory],
          disk: netbox_virtual_machine_params[:disk],
          name: netbox_virtual_machine_params[:name],
          cluster: cluster.id,
          tenant: tenant.id,
          tags: default_tags.map(&:id)
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
