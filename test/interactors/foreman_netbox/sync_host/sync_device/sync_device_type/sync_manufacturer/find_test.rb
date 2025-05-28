# frozen_string_literal: true

require 'test_plugin_helper'

class FindManufacturerTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::SyncManufacturer::Find.call(
      host: host, netbox_params: netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(:host).tap do |host|
      host.stubs(:facts).returns(
        {
          'dmi::manufacturer' => 'Manufacturer',
          'dmi::product::name' => 'device type 2',
        }
      )
    end
  end
  let(:netbox_params) { host.netbox_facet.netbox_params }

  setup do
    setup_default_netbox_settings
  end

  context 'when manufacturer exists in Netbox' do
    context 'by slug' do
      it 'assigns manufacturer to context' do
        stub_get_with_slug = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
          query: { limit: 50, slug: netbox_params.dig(:manufacturer, :slug) }
        ).to_return(
          status: 200, headers: { 'Content-Type': 'application/json' },
          body: {
            count: 1,
            results: [netbox_params.fetch(:manufacturer).merge(id: 1)],
          }.to_json
        )
        stub_get_with_name = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
          query: { limit: 50, name: netbox_params.dig(:manufacturer, :name) }
        )

        assert_equal 1, subject.manufacturer.id
        assert_requested(stub_get_with_slug)
        assert_not_requested(stub_get_with_name)
      end
    end

    context 'by name' do
      it 'assigns manufacturer to context' do
        stub_get_with_slug = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
          query: { limit: 50, slug: netbox_params.dig(:manufacturer, :slug) }
        ).to_return(
          status: 200, headers: { 'Content-Type': 'application/json' },
          body: {
            count: 0,
            results: [],
          }.to_json
        )
        stub_get_with_name = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
          query: { limit: 50, name: netbox_params.dig(:manufacturer, :name) }
        ).to_return(
          status: 200, headers: { 'Content-Type': 'application/json' },
          body: {
            count: 1,
            results: [netbox_params.fetch(:manufacturer).merge(id: 1)],
          }.to_json
        )

        assert_equal 1, subject.manufacturer.id
        assert_requested(stub_get_with_slug)
        assert_requested(stub_get_with_name)
      end
    end
  end

  context 'when manufacturer does not exist in NetBox' do
    it 'does not assign manufacturer to context' do
      stub_get_with_slug = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
        query: { limit: 50, slug: netbox_params.dig(:manufacturer, :slug) }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: [],
        }.to_json
      )

      stub_get_with_name = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/manufacturers/").with(
        query: { limit: 50, name: netbox_params.dig(:manufacturer, :name) }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: [],
        }.to_json
      )

      assert_nil subject.manufacturer
      assert_requested(stub_get_with_slug)
      assert_requested(stub_get_with_name)
    end
  end
end
