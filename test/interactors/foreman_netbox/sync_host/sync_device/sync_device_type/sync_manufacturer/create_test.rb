# frozen_string_literal: true

require 'test_plugin_helper'

class CreateManufacturerTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::SyncManufacturer::Create.call(
      manufacturer: manufacturer, host: host, netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(:host).tap do |host|
      host.stubs(:facts).returns({ 'dmi::manufacturer': 'Manufacturer' })
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when manufacturer is not assigned to the context' do
    let(:manufacturer) { nil }

    it 'assigns manufacturer to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
        body: {
          name: host.netbox_facet.netbox_params.dig(:manufacturer, :name),
          slug: host.netbox_facet.netbox_params.dig(:manufacturer, :slug)
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      assert_equal 1, subject.manufacturer.id
      assert_requested(stub_post)
    end
  end

  context 'when manufacturer is already assigned to the context' do
    let(:manufacturer) { OpenStruct.new }

    it 'does not change manufacturer' do
      assert_equal manufacturer, subject.manufacturer
    end
  end
end
