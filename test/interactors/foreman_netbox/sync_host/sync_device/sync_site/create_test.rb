# frozen_string_literal: true

require 'test_plugin_helper'

class CreateSiteTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncSite::Create.call(host: host, site: site) }

  let(:site_id) { 1 }
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

  context 'when site is not assigned to the context' do
    let(:site) { nil }

    it 'assigns site to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/dcim/sites/").with(
        body: {
          name: host.location.name,
          slug: host.location.name.parameterize
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: site_id }.to_json
      )

      assert_equal site_id, subject.site.id
      assert_requested(stub_post)
    end
  end

  context 'when site is already assigned to the context' do
    let(:site) { OpenStruct.new(id: site_id) }

    it 'does not change site' do
      assert_equal site_id, subject.site.id
    end
  end
end
