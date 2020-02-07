# frozen_string_literal: true

require 'test_plugin_helper'

class FindClusterTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncCluster::Find.call(host: host) }
  let(:host) do
    OpenStruct.new(
      name: 'host.development.example.com',
      compute_object: OpenStruct.new(
        cluster: 'CLUSTER'
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when cluster exists in Netbox' do
    it 'assigns cluster to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/clusters.json").with(
        query: { limit: 50, name: host.compute_object.cluster }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [{ id: 1, name: host.compute_object.cluster }]
        }.to_json
      )

      assert_equal 1, subject.cluster.id
      assert_requested(stub_get)
    end
  end

  context 'when cluster does not exist in NetBox' do
    it 'does not assign cluster to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/clusters.json").with(
        query: { limit: 50, name: host.compute_object.cluster }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.cluster
      assert_requested(stub_get)
    end
  end
end
