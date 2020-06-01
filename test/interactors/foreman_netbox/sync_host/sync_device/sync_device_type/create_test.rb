# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceTypeTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::Create.call(
      device_type: device_type,
      manufacturer: manufacturer,
      host: host
    )
  end

  let(:device_type_id) { 1 }
  let(:manufacturer) { OpenStruct.new(id: 1) }
  let(:host) do
    OpenStruct.new(
      facts: {
        'dmi::product::name': 'Device Type Model'
      }
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when device_type is not assigned to the context' do
    let(:device_type) { nil }

    it 'assigns device_type to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/device-types/").with(
        body: {
          model: host.facts.symbolize_keys.fetch(:'dmi::product::name'),
          slug: host.facts.symbolize_keys.fetch(:'dmi::product::name').parameterize,
          manufacturer: manufacturer.id,
          tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: device_type_id }.to_json
      )

      assert_equal device_type_id, subject.device_type.id
      assert_requested(stub_post)
    end
  end

  context 'when device_type is already assigned to the context' do
    let(:device_type) { OpenStruct.new(id: device_type_id) }

    it 'does not change device_type' do
      assert_equal device_type_id, subject.device_type.id
    end
  end
end
