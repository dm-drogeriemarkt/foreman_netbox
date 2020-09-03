# frozen_string_literal: true

require 'test_plugin_helper'

class CreateTenantTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncTenant::Create.call(
      host: host, tenant: tenant, netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      owner: FactoryBot.build_stubbed(:usergroup, name: 'Owner')
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when tenant is not assigned to the context' do
    let(:tenant) { nil }

    it 'assigns tenant to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/tenancy/tenants/").with(
        body: {
          name: host.owner.name,
          slug: host.owner.name.parameterize,
          tags: ForemanNetbox::NetboxParameters::DEFAULT_TAGS
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      assert_equal 1, subject.tenant.id
      assert_requested(stub_post)
    end
  end

  context 'when tenant is already assigned to the context' do
    let(:tenant) { OpenStruct.new }

    it 'does not change tenant' do
      assert_equal tenant, subject.tenant
    end
  end
end
