# frozen_string_literal: true

require 'test_plugin_helper'

class SyncHostOrganizerTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::Organizer.call(host: host, tags: default_tags) }

  let(:host) do
    FactoryBot.create(:host).tap do |host|
      host.stubs(:interfaces).returns([])
      host.stubs(:facts).returns({ serialnumber: 'abc123' })
    end
  end
  let(:tags) do
    default_tags.map { |t| { 'id' => t.id, 'name' => t.name, 'slug' => t.slug } }
  end

  setup do
    setup_default_netbox_settings
    # rubocop:disable Layout/FirstArrayElementIndentation
    default_tags.each do |tag|
      stub_get_netbox_request("extras/tags/?limit=50&slug=#{tag.slug}", results: [
        { id: tag.id, name: tag.name, slug: tag.slug },
      ])
      stub_request(:get, "#{Setting[:netbox_url]}/api/extras/tags/#{tag.id}/")
        .to_return(
          status: 200, headers: { 'Content-Type': 'application/json' },
          body: {
            id: tag.id,
            name: tag.name,
            slug: tag.slug,
          }.to_json
        )
    end
    stub_get_netbox_request('tenancy/tenants/?limit=50&slug=admin-user', results: [
      { id: 1, name: host.owner.name, slug: host.owner.name.parameterize, tags: tags },
    ])
    stub_get_netbox_request('dcim/sites/?limit=50&slug=location-1', results: [
      { id: 1, name: host.location.netbox_site_name, slug: host.location.netbox_site_slug, tags: tags },
    ])
    stub_get_netbox_request('dcim/device-roles/?limit=50&slug=server', results: [
      { id: 1, name: 'Device Role', slug: 'server' },
    ])
    stub_get_netbox_request('dcim/manufacturers/?limit=50&slug=unknown', results: [
      { id: 1, name: 'Unknown', slug: 'unknown' },
    ])
    stub_get_netbox_request('dcim/device-types/?limit=50&slug=unknown', results: [
      { id: 1, name: 'Unknown', slug: 'unknown', tags: tags },
    ])
    stub_get_netbox_request("dcim/devices/?limit=50&serial=#{host.facts[:serialnumber]}", results: [
      { id: 1, name: host.name, serial: host.facts[:serialnumber], tags: tags },
    ])
    stub_get_netbox_request('dcim/interfaces/?device_id=1&limit=50', results: [])
    stub_get_netbox_request('ipam/ip-addresses/?device_id=1&limit=50', results: [])
    # rubocop:enable Layout/FirstArrayElementIndentation
  end

  test 'save synchronization status when it succeeds' do
    stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/1/").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: { id: 1 }.to_json
    )
    subject
    host.reload

    assert_not_nil host.netbox_facet.synchronized_at
    assert_equal "#{Setting[:netbox_url]}/dcim/devices/1", host.netbox_facet.url
    assert_nil host.netbox_facet.synchronization_error
  end

  test 'save synchronization status when it fails' do
    stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/devices/1/").to_return(
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
    stub_request(:get, "#{Setting[:netbox_url]}/api/#{path}").to_return(
      status: 200, headers: { 'Content-Type': 'application/json' },
      body: {
        count: 1,
        results: results,
      }.to_json
    )
  end
end
