# frozen_string_literal: true

require 'test_plugin_helper'

class SaveNetboxUrlVirtualMachineTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SaveNetboxUrl.call(host: host, virtual_machine: virtual_machine)
  end

  let(:virtual_machine) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when a host has Netbox facet' do
    let(:host) { FactoryBot.create(:host, :with_netbox_facet, hostname: 'host.dev.example.com') }

    it 'updates Netbox facet' do
      assert_not_nil host.netbox_facet
      assert_difference('ForemanNetbox::NetboxFacet.count', 0) do
        subject
      end
      assert_equal 'https://netbox.example.com/virtualization/virtual-machines/1', subject.host.reload.netbox_facet.url
    end
  end

  context 'when a host has no Netbox facet' do
    let(:host) { FactoryBot.create(:host, hostname: 'host.dev.example.com') }

    it 'creates Netbox facet' do
      assert_nil host.netbox_facet
      assert_difference('ForemanNetbox::NetboxFacet.count', 1) do
        subject
      end
      assert_equal 'https://netbox.example.com/virtualization/virtual-machines/1', subject.host.reload.netbox_facet.url
    end
  end
end
