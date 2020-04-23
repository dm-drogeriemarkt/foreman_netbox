# frozen_string_literal: true

require 'test_plugin_helper'

class FindClusterTypeTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Find.call(host: host) }

  let(:cluster_type_params) do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Organizer::CLUSTER_TYPES[cluster_type]
  end

  let(:cluster_type) { :'Foreman::Model::Vmware' }
  let(:host) do
    OpenStruct.new(
      name: 'host.development.example.com',
      compute_resource: OpenStruct.new(
        type: cluster_type
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when cluster type exists in Netbox' do
    it 'assigns cluster_type to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/cluster-types.json").with(
        query: { limit: 50, slug: cluster_type_params[:slug] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: cluster_type_params[:name],
              slug: cluster_type_params[:slug]
            }
          ]
        }.to_json
      )

      assert_equal 1, subject.cluster_type.id
      assert_requested(stub_get)
    end
  end

  context 'when cluster type does not exist in NetBox' do
    it 'does not assign cluster_type to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/cluster-types.json").with(
        query: { limit: 50, slug: cluster_type_params[:slug] }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.cluster_type
      assert_requested(stub_get)
    end
  end
end
