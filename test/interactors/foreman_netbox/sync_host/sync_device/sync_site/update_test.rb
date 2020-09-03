# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateSiteTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncSite::Update.call(
      host: host, site: site, netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) { FactoryBot.build_stubbed(:host) }
  let(:site) do
    ForemanNetbox::API.client::DCIM::Site.new(id: 1).tap do |site|
      site.instance_variable_set(
        :@data,
        { 'id' => 1, 'tags' => site_tags }
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when changed' do
    let(:site_tags) { [] }

    it 'updates site' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/sites/1.json").with(
        body: {
          tags: host.netbox_facet.netbox_params.dig(:site, :tags)
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
    let(:site_tags) { host.netbox_facet.netbox_params.dig(:site, :tags) }

    it 'does not update site' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/dcim/sites/1.json")

      assert subject.success?
      assert_not_requested stub_patch
    end
  end
end
