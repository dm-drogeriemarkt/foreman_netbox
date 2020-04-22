# frozen_string_literal: true

require 'test_plugin_helper'

class CreateDeviceRoleTest < ActiveSupport::TestCase
  let(:klass) { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceRole::Create }
  let(:device_role_params) { klass.new }

  subject { klass.call(device_role: device_role) }

  setup do
    setup_default_netbox_settings
  end

  context 'when device_role is not assigned to the context' do
    let(:device_role) { nil }

    it 'assigns device_role to context' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/dcim/device-roles/").with(
        body: {
          name: device_role_params.name,
          slug: device_role_params.slug,
          color: device_role_params.color
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
