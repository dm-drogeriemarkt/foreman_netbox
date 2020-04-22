# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateClusterTypeTest < ActiveSupport::TestCase
  let(:interactor) { ForemanNetbox::ValidateHost::ValidateVirtualMachine::ValidateCluster::ValidateClusterType::Validate }
  subject { interactor.call(host: host) }

  context 'with valid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_resource: OpenStruct.new(
          type: 'Foreman::Model::Vmware'
        )
      )
    end

    it { assert subject.success? }
  end

  context 'with invalid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_resource: OpenStruct.new
      )
    end

    it { assert_not subject.success? }
  end
end
