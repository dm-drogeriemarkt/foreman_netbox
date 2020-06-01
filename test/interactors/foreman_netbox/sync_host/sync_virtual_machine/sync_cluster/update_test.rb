# frozen_string_literal: true

require 'test_plugin_helper'

class UpdateClusterTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::Update.call(cluster: cluster) }

  let(:cluster) do
    ForemanNetbox::API.client::Virtualization::Cluster.new(id: 1).tap do |cluster|
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
          tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
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
    let(:cluster_tags) { ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS }

    it 'does not update cluster' do
      stub_patch = stub_request(:patch, "#{Setting[:netbox_url]}/api/virtualization/clusters/1.json")

      assert subject.success?
      assert_not_requested stub_patch
    end
  end
end
