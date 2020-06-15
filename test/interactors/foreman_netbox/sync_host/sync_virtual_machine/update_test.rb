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
    ForemanNetbox::API.client::Virtualization::VirtualMachine.new(id: 1).tap do |virtual_machine|
      virtual_machine.instance_variable_set(
        :@data,
        {
          'id' => 1,
          'name' => virtual_machine_name,
          'cluster' => { 'id' => 1 },
          'tenant' => { 'id' => 1 },
          'vcpus' => 2,
          'memory' => 128,
          'disk' => 512,
          'primary_ip4' => {
            'id' => 1,
            'family' => 4,
            'address' => '10.0.0.1/24'
          },
          'primary_ip6' => {
            'id' => 2,
            'family' => 6,
            'address' => '1600:0:2d0:201::18/64'
          },
          'tags' => virtual_machine_tags
        }
      )
    end
  end

  let(:virtual_machine_name) { 'name.example.com' }
  let(:virtual_machine_tags) { ['tag'] }
  let(:virtual_machine_data) { virtual_machine.instance_variable_get(:@data).deep_symbolize_keys }
  let(:cluster) { OpenStruct.new(id: virtual_machine_data.dig(:cluster, :id)) }
  let(:tenant) { OpenStruct.new(id: virtual_machine_data.dig(:tenant, :id)) }
  let(:primary_ip4) do
    OpenStruct.new(
      id: virtual_machine_data.dig(:primary_ip4, :id),
      address: OpenStruct.new(
        address: virtual_machine_data.dig(:primary_ip4, :address).split('/')[0]
      )
    )
  end
  let(:primary_ip6) do
    OpenStruct.new(
      id: virtual_machine_data.dig(:primary_ip6, :id),
      address: OpenStruct.new(
        address: virtual_machine_data.dig(:primary_ip6, :address).split('/')[0]
      )
    )
  end
  let(:ip_addresses) { ForemanNetbox::API.client.ipam.ip_addresses.filter(virtual_machine_id: virtual_machine.id) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      hostname: virtual_machine_name,
      ip: primary_ip4.address.address,
      ip6: primary_ip6.address.address
    ).tap do |host|
      host.stubs(:compute_object).returns(
        OpenStruct.new(
          cpus: virtual_machine_data[:vcpus],
          memory_mb: virtual_machine_data[:memory],
          volumes: [
            OpenStruct.new(size_gb: virtual_machine_data[:disk])
          ]
        )
      )
    end
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, virtual_machine_id: virtual_machine.id }
    ).to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 2,
        results: [
          { id: primary_ip4.id, address: primary_ip4.address.address },
          { id: primary_ip6.id, address: primary_ip6.address.address }
        ]
      }.to_json
    )
  end

  context 'if the host has not been updated since the last synchronization' do
    let(:virtual_machine_tags) { ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS }

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
      FactoryBot.build_stubbed(
        :host,
        ip: primary_ip4.address.address,
        ip6: primary_ip6.address.address
      ).tap do |host|
        host.stubs(:compute_object).returns(
          OpenStruct.new(
            cpus: 4,
            memory_mb: 256,
            volumes: [
              OpenStruct.new(size_gb: 1024)
            ]
          )
        )
      end
    end

    it 'updates virtual_machine' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/virtual-machines/#{virtual_machine.id}.json").with(
        body: {
          name: host.name,
          cluster: cluster.id,
          disk: host.compute_object.volumes.map(&:size_gb).reduce(&:+),
          memory: host.compute_object.memory_mb,
          primary_ip4: primary_ip4.id,
          primary_ip6: primary_ip6.id,
          tenant: tenant.id,
          vcpus: host.compute_object.cpus,
          tags: virtual_machine_tags | ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
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
