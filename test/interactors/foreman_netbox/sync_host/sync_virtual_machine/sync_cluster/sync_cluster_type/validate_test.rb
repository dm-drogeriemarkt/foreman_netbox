# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateClusterTypeTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Validate.call(host: host) }

  context 'with valid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_resource: OpenStruct.new(
          type: 'Foreman::Model::Vmware'
        )
      )
    end

    it 'does not raise an error' do
      assert_nothing_raised { subject }
    end
  end

  context 'with invalid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_resource: OpenStruct.new
      )
    end

    it 'raises an error' do
      assert_raises ForemanNetbox::SyncHost::ValidationOrganizer::HostAttributeError do
        subject
      end
    end
  end
end
