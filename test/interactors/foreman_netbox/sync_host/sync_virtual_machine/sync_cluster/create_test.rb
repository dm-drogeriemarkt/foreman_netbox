# frozen_string_literal: true

require 'test_plugin_helper'

class CreateClusterTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::Create.call(
      host: host,
      cluster_type: cluster_type,
      cluster: cluster,
      netbox_params: host.netbox_facet.netbox_params,
      tags: default_tags
    )
  end

  let(:cluster_id) { 1 }
  let(:cluster_type) { OpenStruct.new(id: 1) }
  let(:host) do
    FactoryBot.build_stubbed(:host).tap do |host|
      host.stubs(:compute?).returns(true)
      host.stubs(:compute_object).returns(
        OpenStruct.new(cluster: 'CLUSTER')
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when cluster is not assigned to the context' do
    let(:cluster) { nil }

    it 'creates a cluster' do
      stub_post = stub_request(:post, "#{Setting[:netbox_url]}/api/virtualization/clusters/").with(
        body: {
          name: host.netbox_facet.netbox_params.dig(:cluster, :name),
          type: cluster_type.id,
          tags: default_tags.map(&:id)
        }.to_json
      ).to_return(
        status: 201, headers: { 'Content-Type': 'application/json' },
        body: { id: cluster_id }.to_json
      )

      assert_equal cluster_id, subject.cluster.id
      assert_requested(stub_post)
    end
  end

  context 'when cluster is already assigned to the context' do
    let(:cluster) { OpenStruct.new(id: cluster_id) }

    it 'does not create a cluster' do
      assert_equal cluster_id, subject.cluster.id
    end
  end
end
