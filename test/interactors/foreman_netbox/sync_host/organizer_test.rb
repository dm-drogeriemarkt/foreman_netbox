# frozen_string_literal: true

require 'test_plugin_helper'

class SyncHostOrganizerTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::Organizer.call(host: host) }

  let(:host) do
    FactoryBot.create(:host).tap do |host|
      host.stubs(:interfaces).returns([])
      host.stubs(:facts).returns({ serialnumber: 'abc123' })
    end
  end
  let(:tags) { ForemanNetbox::NetboxParameters::DEFAULT_TAGS }

  setup do
    setup_default_netbox_settings
    # rubocop:disable Layout/FirstArrayElementIndentation
    stub_get_netbox_request('tenancy/tenants.json?limit=50&slug=admin-user', results: [
      { id: 1, name: host.owner.name, slug: host.owner.name.parameterize, tags: tags }
    ])
    stub_get_netbox_request('dcim/sites.json?limit=50&slug=location-1', results: [
      { id: 1, name: host.location.netbox_site_name, slug: host.location.netbox_site_slug, tags: tags }
    ])
    stub_get_netbox_request('dcim/device-roles.json?limit=50&slug=server', results: [
      { id: 1, name: 'Device Role', slug: 'server' }
    ])
    stub_get_netbox_request('dcim/manufacturers.json?limit=50&slug=unknown', results: [
      { id: 1, name: 'Unknown', slug: 'unknown' }
    ])
    stub_get_netbox_request('dcim/device-types.json?limit=50&slug=unknown', results: [
      { id: 1, name: 'Unknown', slug: 'unknown', tags: tags }
    ])
    stub_get_netbox_request("dcim/devices.json?limit=50&serial=#{host.facts[:serialnumber]}", results: [
      { id: 1, name: host.name, serial: host.facts[:serialnumber], tags: tags }
    ])
    stub_get_netbox_request('dcim/interfaces.json?device_id=1&limit=50', results: [])
    stub_get_netbox_request('ipam/ip-addresses.json?device_id=1&limit=50', results: [])
    # rubocop:enable Layout/FirstArrayElementIndentation
  end

  test 'save synchronization status when it succeeds' do
    stub_request(:patch, "#{Setting::Netbox[:netbox_url]}/api/dcim/devices/1.json").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: { id: 1 }.to_json
    )
    subject
    host.reload

    assert_not_nil host.netbox_facet.synchronized_at
    assert_equal "#{Setting::Netbox[:netbox_url]}/dcim/devices/1", host.netbox_facet.url
    assert_nil host.netbox_facet.synchronization_error
  end

  test 'save synchronization status when it fails' do
    stub_request(:patch, "#{Setting::Netbox[:netbox_url]}/api/dcim/devices/1.json").to_return(
      status: 500, headers: { 'Content-Type': 'application/json' }
    )
    subject
    host.reload

    assert_not_nil host.netbox_facet.synchronized_at
    assert_nil host.netbox_facet.url
    assert_equal 'ForemanNetbox::SyncHost::SyncDevice::Update: 500 Remote Error', host.netbox_facet.synchronization_error
  end

  private

  def stub_get_netbox_request(path, results:)
    stub_request(:get, "#{Setting::Netbox[:netbox_url]}/api/#{path}").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: results
      }.to_json
    )
  end
end
