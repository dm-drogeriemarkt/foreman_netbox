# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class UsergroupTest < ActiveSupport::TestCase
    describe '#netbox_tenant_name' do
      let(:usergroup) { FactoryBot.build_stubbed(:usergroup, id: 1, name: usergroup_name) }

      context 'when name is longer than 100' do
        let(:usergroup_name) { SecureRandom.hex(64) }

        it { assert_equal "#{usergroup.name.truncate(98, omission: '')}-#{usergroup.id}", usergroup.netbox_tenant_name }
      end

      context 'when name is shorter than 100' do
        let(:usergroup_name) { 'Name' }

        it { assert_equal usergroup.name, usergroup.netbox_tenant_name }
      end
    end
  end
end
