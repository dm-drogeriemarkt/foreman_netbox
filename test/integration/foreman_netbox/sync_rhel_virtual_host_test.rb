# frozen_string_literal: true

require 'test_plugin_helper'

class SyncRhelVirtualHostTest < ActiveSupport::TestCase
  setup do
    setup_netbox_integration_test
  end

  let(:hostname) { 'rhel_virtual_host' }
  let(:file) { file_fixture("facts/#{hostname}.json").read }
  let(:facts_json) { JSON.parse(file) }
  let(:ip) { '10.0.0.7' }
  let(:ip6) { '1600:0:2d0:202::17' }
  let(:host) do
    OpenStruct.new(
      name: "#{hostname}.tier.example.com",
      ip: ip,
      ip6: ip6,
      compute?: true,
      owner_type: 'Usergroup',
      owner: OpenStruct.new(name: 'Owner'),
      location: FactoryBot.build_stubbed(:location, name: 'Location'),
      compute_resource: OpenStruct.new(type: 'Foreman::Model::Vmware'),
      compute_object: OpenStruct.new(
        cluster: 'CLUSTER',
        cpus: 1,
        memory_mb: 1024,
        volumes: [
          OpenStruct.new(size_gb: 120)
        ]
      ),
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth0',
          mac: 'C3:CD:63:54:21:60',
          ip: ip,
          subnet: FactoryBot.build_stubbed(
            :subnet_ipv4,
            organizations: [],
            locations: []
          )
        ),
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth1',
          mac: '45:E9:6A:83:02:20',
          ip6: ip6,
          subnet6: FactoryBot.build_stubbed(
            :subnet_ipv6,
            organizations: [],
            locations: []
          )
        )
      ],
      facts: facts_json
    )
  end

  test 'sync host' do
    VCR.use_cassette "push_#{hostname}", match_requests_on: %i[uri method] do
      result = ForemanNetbox::SyncHost::Organizer.call(host: host)

      assert result.success?
    end
  end
end
