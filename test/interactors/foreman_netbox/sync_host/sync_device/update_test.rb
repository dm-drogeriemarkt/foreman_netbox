# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateDeviceTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::Update.call(
      device: device,
      host: host,
      device_role: device_role,
      device_type: device_type,
      cluster: cluster,
      site: site,
      tenant: tenant,
      ip_addresses: ip_addresses
    )
  end

  let(:device) do
    NetboxClientRuby::DCIM::Device.new(
      id: 1,
      device_role: OpenStruct.new(id: 1),
      device_type: OpenStruct.new(id: 1),
      site: OpenStruct.new(id: 1),
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
      cluster: {
        id: 1
      }
    )
  end

  let(:device_role) { device.device_role }
  let(:device_type) { device.device_type }
  let(:site) { device.site }
  let(:cluster) { OpenStruct.new(id: device.cluster.fetch(:id)) }
  let(:tenant) { device.tenant }
  let(:primary_ip4) { device.primary_ip4 }
  let(:primary_ip6) { device.primary_ip6 }
  let(:ip_addresses) { [primary_ip4, primary_ip6] }
  let(:host) do
    OpenStruct.new(
      ip: primary_ip4.address.address,
      ip6: primary_ip6.address.address
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'if the host has not been updated since the last synchronization' do
    it 'does not update device' do
      assert_equal device, subject.device
    end
  end

  context 'if the host has been updated since the last synchronization' do
    let(:device_role) { OpenStruct.new(id: 2) }
    let(:device_type) { OpenStruct.new(id: 2) }
    let(:site) { OpenStruct.new(id: 2) }
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
        ip6: primary_ip6.address.address
      )
    end

    it 'updates device' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/#{device.id}.json").with(
        body: {
          device_role: device_role.id,
          device_type: device_type.id,
          site: site.id,
          tenant: tenant.id,
          primary_ip4: primary_ip4.id,
          primary_ip6: primary_ip6.id,
          cluster: cluster.id
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
