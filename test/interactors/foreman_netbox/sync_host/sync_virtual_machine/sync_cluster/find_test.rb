# frozen_string_literal: true

require 'test_plugin_helper'

class FindClusterTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::Find.call(
      host: host, netbox_params: host.netbox_facet.netbox_params
    )
  end

  let(:host) do
    FactoryBot.build_stubbed(:host, hostname: 'host.dev.example.com').tap do |host|
      host.stubs(:compute?).returns(true)
      host.stubs(:compute_object).returns(
        OpenStruct.new(cluster: 'CLUSTER')
      )
    end
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when cluster exists in Netbox' do
    it 'assigns cluster to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/clusters/").with(
        query: { limit: 50, name: host.compute_object.cluster }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [{ id: 1, name: host.compute_object.cluster }],
        }.to_json
      )

      assert_equal 1, subject.cluster.id
      assert_requested(stub_get)
    end
  end

  context 'when cluster does not exist in NetBox' do
    it 'does not assign cluster to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/virtualization/clusters/").with(
        query: { limit: 50, name: host.compute_object.cluster }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: [],
        }.to_json
      )

      assert_nil subject.cluster
      assert_requested(stub_get)
    end
  end
end
