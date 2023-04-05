# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceRoleTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncDeviceRole::Create.call(
      host: host, netbox_params: host.netbox_facet.netbox_params, device_role: device_role
    )
  end
  let(:device_role_params) { host.netbox_facet.netbox_params.fetch(:device_role) }
  let(:host) { FactoryBot.build_stubbed(:host) }

  setup do
    setup_default_netbox_settings
  end

  context 'when device_role is not assigned to the context' do
    let(:device_role) { nil }

    it 'assigns device_role to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/device-roles/").with(
        body: {
          name: device_role_params[:name],
          color: device_role_params[:color],
          slug: device_role_params[:slug],
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      assert_equal 1, subject.device_role.id
      assert_requested(stub_post)
    end
  end

  context 'when device_role is already assigned to the context' do
    let(:device_role) { OpenStruct.new }

    it 'does not change device_role' do
      assert_equal device_role, subject.device_role
    end
  end
end
