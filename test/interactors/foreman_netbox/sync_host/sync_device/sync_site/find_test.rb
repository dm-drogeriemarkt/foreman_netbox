# frozen_string_literal: true

require 'test_plugin_helper'

class FindSiteTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncSite::Find.call(
      host: host,
      netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      location: FactoryBot.build_stubbed(:location)
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when site exists in Netbox' do
    it 'assigns site to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/sites.json").with(
        query: { limit: 50, slug: host.location.netbox_site_slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            { id: 1, name: host.location.netbox_site_name, slug: host.location.netbox_site_slug }
          ]
        }.to_json
      )

      assert_equal 1, subject.site.id
      assert_requested(stub_get)
    end
  end

  context 'when site does not exist in NetBox' do
    it 'does not assign site to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/sites.json").with(
        query: { limit: 50, slug: host.location.netbox_site_slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.site
      assert_requested(stub_get)
    end
  end
end
