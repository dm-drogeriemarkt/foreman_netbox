# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateDeviceTypeTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::Update.call(device_type: device_type) }

  let(:device_type) do
    ForemanNetbox::API.client::DCIM::DeviceType.new(id: 1).tap do |device|
      device.instance_variable_set(
        :@data,
        { 'id' => 1, 'tags' => device_type_tags }
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when changed' do
    let(:device_type_tags) { [] }

    it 'updates device type' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/device-types/1.json").with(
        body: {
          tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
        }.to_json
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      assert subject.success?
      assert_requested stub_patch
    end
  end

  context 'when unchanged' do
    let(:device_type_tags) { ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS }

    it 'does not update device type' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/device-types/1.json")

      assert subject.success?
      assert_not_requested stub_patch
    end
  end
end
