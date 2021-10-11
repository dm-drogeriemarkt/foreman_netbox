# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateDeviceTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::Update.call(
      device: device,
      host: host,
      netbox_params: host.netbox_facet.netbox_params,
      device_role: device_role,
      device_type: device_type,
      site: site,
      tenant: tenant,
      ip_addresses: ip_addresses,
      tags: default_tags
    )
  end

  let(:device) do
    ForemanNetbox::API.client::DCIM::Device.new(id: 1).tap do |device|
      device.instance_variable_set(
        :@data,
        {
          'id' => 1,
          'name' => device_name,
          'device_role' => { 'id' => 1 },
          'device_type' => { 'id' => 1 },
          'site' => { 'id' => 1 },
          'tenant' => { 'id' => 1 },
          'serial' => 'old123',
          'primary_ip4' => {
            'id' => 1,
            'family' => 4,
            'address' => '10.0.0.8/24'
          },
          'primary_ip6' => {
            'id' => 2,
            'family' => 6,
            'address' => '1600:0:2d0:202::18/64'
          },
          'tags' => device_tags
        }
      )
    end
  end
  let(:device_name) { 'name.example.com' }
  let(:device_tags) { [] }
  let(:device_data) { device.instance_variable_get(:@data).deep_symbolize_keys }
  let(:device_role) { OpenStruct.new(id: device_data.dig(:device_role, :id)) }
  let(:device_type) { OpenStruct.new(id: device_data.dig(:device_type, :id)) }
  let(:site) { OpenStruct.new(id: device_data.dig(:site, :id)) }
  let(:tenant) { OpenStruct.new(id: device_data.dig(:tenant, :id)) }
  let(:primary_ip4) do
    OpenStruct.new(
      id: device_data.dig(:primary_ip4, :id),
      address: OpenStruct.new(
        address: device_data.dig(:primary_ip4, :address).split('/')[0]
      )
    )
  end
  let(:primary_ip6) do
    OpenStruct.new(
      id: device_data.dig(:primary_ip6, :id),
      address: OpenStruct.new(
        address: device_data.dig(:primary_ip6, :address).split('/')[0]
      )
    )
  end
  let(:serialnumber) { device_data[:serial] }
  let(:ip_addresses) { ForemanNetbox::API.client.ipam.ip_addresses.filter(device_id: device.id) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      hostname: device_name,
      ip: primary_ip4.address.address,
      ip6: primary_ip6.address.address
    ).tap do |host|
      host.stubs(:facts).returns({ 'serialnumber' => serialnumber })
    end
  end

  setup do
    setup_default_netbox_settings
    stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
      query: { limit: 50, device_id: device.id }
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
    let(:device_tags) do
      default_tags.map { |t| { 'id' => t.id, 'name' => t.name, 'slug' => t.slug } }
    end

    it 'does not update device' do
      device_tags.each do |t|
        stub_request(:get, "#{Setting[:netbox_url]}/api/extras/tags/#{t['id']}.json")
          .to_return(
            status: 200, headers: { 'Content-Type': 'application/json' },
            body: {
              id: t['id'],
              name: t['name'],
              slug: t['slug']
            }.to_json
          )
      end
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/#{device.id}.json")

      assert_equal device, subject.device
      assert_not_requested(stub_patch)
    end
  end

  context 'if the host has been updated since the last synchronization' do
    let(:device_role) { OpenStruct.new(id: 2) }
    let(:device_type) { OpenStruct.new(id: 2) }
    let(:site) { OpenStruct.new(id: 2) }
    let(:tenant) { OpenStruct.new(id: 2) }
    let(:serialnumber) { 'new123' }
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
        host.stubs(:facts).returns({ 'serialnumber' => serialnumber })
      end
    end

    it 'updates device' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/#{device.id}.json").with(
        body: {
          name: host.name,
          device_role: device_role.id,
          device_type: device_type.id,
          primary_ip4: primary_ip4.id,
          primary_ip6: primary_ip6.id,
          site: site.id,
          tenant: tenant.id,
          serial: serialnumber,
          tags: default_tags.map(&:id)
        }.to_json
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      subject
      assert_requested(stub_patch)
    end

    context 'when serialnumber is empty' do
      let(:serialnumber) { nil }

      it 'updates device' do
        stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/#{device.id}.json").with(
          body: {
            name: host.name,
            device_role: device_role.id,
            device_type: device_type.id,
            primary_ip4: primary_ip4.id,
            primary_ip6: primary_ip6.id,
            site: site.id,
            tenant: tenant.id,
            tags: default_tags.map(&:id)
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
end
