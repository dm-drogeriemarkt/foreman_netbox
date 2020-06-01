# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateTenantTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncTenant::Update.call(tenant: tenant) }

  let(:tenant) do
    ForemanNetbox::API.client::Tenancy::Tenant.new(id: 1).tap do |tenant|
      tenant.instance_variable_set(
        :@data,
        { 'id' => 1, 'tags' => tenant_tags }
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when changed' do
    let(:tenant_tags) { [] }

    it 'updates tenant' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/tenancy/tenants/1.json").with(
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
    let(:tenant_tags) { ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS }

    it 'does not update tenant' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/tenancy/tenants/1.json")

      assert subject.success?
      assert_not_requested stub_patch
    end
  end
end
