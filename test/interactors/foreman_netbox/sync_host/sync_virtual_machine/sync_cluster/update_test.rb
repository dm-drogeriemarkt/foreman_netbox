# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateClusterTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::Update.call(
      host: host, cluster: cluster, netbox_params: host.netbox_facet.netbox_params, tags: default_tags
    )
  end

  let(:host) { FactoryBot.build_stubbed(:host).tap { |h| h.stubs(:compute?).returns(true) } }
  let(:cluster) do
    ForemanNetbox::Api.client::Virtualization::Cluster.new(id: 1).tap do |cluster|
      cluster.instance_variable_set(
        :@data,
        { 'id' => 1, 'tags' => cluster_tags }
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when changed' do
    let(:cluster_tags) { [] }

    it 'updates cluster' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/clusters/1.json").with(
        body: {
          tags: default_tags.map(&:id),
        }.to_json
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: { id: 1 }.to_json
      )

      assert subject.success?
      assert_requested stub_patch
    end
  end

  context 'when unchanged' do
    let(:cluster_tags) do
      default_tags.map { |t| { 'id' => t.id, 'name' => t.name, 'slug' => t.slug } }
    end

    it 'does not update cluster' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/clusters/1.json")

      assert subject.success?
      assert_not_requested stub_patch
    end
  end
end
