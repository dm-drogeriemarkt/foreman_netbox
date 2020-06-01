# frozen_string_literal: true

require 'test_plugin_helper'

class CreateClusterTypeTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Create.call(
      host: host, cluster_type: cluster_type
    )
  end

  let(:cluster_type_id) { 1 }
  let(:cluster_type_params) do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Organizer::CLUSTER_TYPES[:'Foreman::Model::Vmware']
  end
  let(:host) do
    OpenStruct.new(
      compute_resource: OpenStruct.new(
        type: 'Foreman::Model::Vmware'
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when cluster_type is not assigned to the context' do
    let(:cluster_type) { nil }

    it 'creates a cluster_type' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/virtualization/cluster-types/").with(
        body: cluster_type_params.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: cluster_type_id }.to_json
      )

      assert_equal cluster_type_id, subject.cluster_type.id
      assert_requested(stub_post)
    end
  end

  context 'when cluster_type is already assigned to the context' do
    let(:cluster_type) { OpenStruct.new(id: cluster_type_id) }

    it 'does not create a cluster_type' do
      assert_equal cluster_type_id, subject.cluster_type.id
    end
  end
end
