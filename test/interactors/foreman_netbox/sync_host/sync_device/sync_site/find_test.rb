# frozen_string_literal: true

require 'test_plugin_helper'

class FindSiteTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncSite::Find.call(host: host) }

  let(:host) do
    OpenStruct.new(
      location: OpenStruct.new(
        name: 'Location'
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when site exists in Netbox' do
    it 'assigns site to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/dcim/sites.json").with(
        query: { limit: 50, slug: host.location.name.parameterize }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            { id: 1, name: host.location.name, slug: host.location.name.parameterize }
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
        query: { limit: 50, slug: host.location.name.parameterize }
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
