# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::Create.call(
      host: host,
      device_type: device_type,
      device_role: device_role,
      site: site,
      tenant: tenant,
      device: device
    )
  end

  let(:device_id) { 1 }
  let(:host) do
    FactoryBot.build_stubbed(:host, hostname: 'host.dev.example.com').tap do |host|
      host.stubs(:facts).returns({ 'serialnumber' => 'abc123' })
    end
  end
  let(:device_type) { OpenStruct.new(id: 1) }
  let(:device_role) { OpenStruct.new(id: 1) }
  let(:site) { OpenStruct.new(id: 1) }
  let(:tenant) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when device is not assigned to the context' do
    let(:device) { nil }

    it 'creates a device' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/devices/").with(
        body: {
          device_type: device_type.id,
          device_role: device_role.id,
          site: site.id,
          name: host.name,
          tenant: tenant.id,
          serial: host.facts['serialnumber']
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: device_id }.to_json
      )

      assert_equal device_id, subject.device.id
      assert_requested(stub_post)
    end
  end

  context 'when device is already assigned to the context' do
    let(:device) { OpenStruct.new(id: device_id) }

    it 'does not create a device' do
      assert_equal device_id, subject.device.id
    end
  end
end
