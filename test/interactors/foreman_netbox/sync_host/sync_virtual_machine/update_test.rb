# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateVirtualMachineTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::Update.call(
      virtual_machine: virtual_machine,
      host: host,
      cluster: cluster,
      tenant: tenant,
      ip_addresses: ip_addresses
    )
  end

  let(:virtual_machine) do
    NetboxClientRuby::Virtualization::VirtualMachine.new(
      id: 1,
      cluster: OpenStruct.new(id: 1),
      tenant: OpenStruct.new(id: 1),
      primary_ip4: OpenStruct.new(
        id: 1,
        address: OpenStruct.new(
          address: '10.0.0.1'
        )
      ),
      primary_ip6: OpenStruct.new(
        id: 2,
        address: OpenStruct.new(
          address: '1500:0:2d0:201::1'
        )
      ),
      vcpus: 2,
      memory: 512,
      disk: 128
    )
  end
  let(:cluster) { virtual_machine.cluster }
  let(:tenant) { virtual_machine.tenant }
  let(:primary_ip4) { virtual_machine.primary_ip4 }
  let(:primary_ip6) { virtual_machine.primary_ip6 }
  let(:ip_addresses) { [primary_ip4, primary_ip6] }
  let(:host) do
    OpenStruct.new(
      ip: primary_ip4.address.address,
      ip6: primary_ip6.address.address,
      compute_object: OpenStruct.new(
        cpus: virtual_machine.vcpus,
        memory_mb: virtual_machine.memory,
        volumes: [
          OpenStruct.new(size_gb: virtual_machine.disk)
        ]
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'if the host has not been updated since the last synchronization' do
    it 'does not update virtual_machine' do
      assert_equal virtual_machine, subject.virtual_machine
    end
  end

  context 'if the host has been updated since the last synchronization' do
    let(:cluster) { OpenStruct.new(id: 2) }
    let(:tenant) { OpenStruct.new(id: 2) }
    let(:primary_ip4) do
      OpenStruct.new(
        id: 3,
        address: OpenStruct.new(
          address: '10.0.0.2'
        )
      )
    end
    let(:primary_ip6) do
      OpenStruct.new(
        id: 4,
        address: OpenStruct.new(
          address: '1500:0:2d0:201::2'
        )
      )
    end
    let(:host) do
      OpenStruct.new(
        ip: primary_ip4.address.address,
        ip6: primary_ip6.address.address,
        compute_object: OpenStruct.new(
          cpus: virtual_machine.vcpus * 2,
          memory_mb: virtual_machine.memory * 2,
          volumes: [
            OpenStruct.new(size_gb: virtual_machine.disk * 2)
          ]
        )
        # facts: {
        #   'processors::count': virtual_machine.vcpus * 2,
        #   memorysize_mb: virtual_machine.memory * 2,
        #   blockdevice_sda_size: virtual_machine.disk * 2 * Numeric::GIGABYTE
        # }
      )
    end

    it 'updates virtual_machine' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines/#{virtual_machine.id}.json").with(
        body: {
          cluster: cluster.id,
          tenant: tenant.id,
          primary_ip4: primary_ip4.id,
          primary_ip6: primary_ip6.id,
          vcpus: host.compute_object.cpus,
          memory: host.compute_object.memory_mb,
          disk: host.compute_object.volumes.map(&:size_gb).reduce(&:+)
        }.to_json
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      subject
      assert_requested(stub_patch)
    end
  end
end
