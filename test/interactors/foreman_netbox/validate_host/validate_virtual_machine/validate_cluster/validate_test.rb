# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateClusterTest < ActiveSupport::TestCase
  let(:interactor) { ForemanNetbox::ValidateHost::ValidateVirtualMachine::ValidateCluster::Validate }
  subject { interactor.call(host: host) }

  context 'with valid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_object: OpenStruct.new(
          cluster: 'CLUSTER'
        )
      )
    end

    it { assert subject.success? }
  end

  context 'with invalid attributes' do
    let(:host) do
      OpenStruct.new(
        compute_object: OpenStruct.new
      )
    end

    it { assert_not subject.success? }
  end
end
