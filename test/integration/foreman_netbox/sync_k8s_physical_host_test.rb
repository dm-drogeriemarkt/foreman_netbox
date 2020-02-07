# frozen_string_literal: true

require 'test_plugin_helper'

class SyncK8sPhysicalHostTest < ActiveSupport::TestCase
  setup do
    setup_netbox_integration_test
  end

  let(:hostname) { 'k8s_physical_host' }
  let(:file) { file_fixture("facts/#{hostname}.json").read }
  let(:facts_json) { JSON.parse(file) }
  let(:ip) { '10.0.0.7' }
  let(:ip6) { '1600:0:2d0:202::17' }
  let(:host) do
    OpenStruct.new(
      name: "#{hostname}.tier.example.com",
      ip: ip,
      ip6: ip6,
      compute?: false,
      owner_type: 'Usergroup',
      owner: OpenStruct.new(name: 'Owner'),
      location: OpenStruct.new(name: 'Location'),
      compute_resource: OpenStruct.new(type: 'Foreman::Model::Vmware'),
      compute_object: OpenStruct.new(cluster: 'CLUSTER'),
      interfaces: [
        OpenStruct.new(
          name: 'INT1',
          mac: 'C3:CD:63:54:21:60',
          subnet: OpenStruct.new(
            network_address: "#{ip}/24"
          )
        ),
        OpenStruct.new(
          name: 'INT2',
          mac: '45:E9:6A:83:02:20',
          subnet6: OpenStruct.new(
            network_address: "#{ip6}/32"
          )
        )
      ],
      facts: facts_json
    )
  end

  test 'sync host' do
    VCR.use_cassette "push_#{hostname}" do
      result = ForemanNetbox::SyncHost::Organizer.call(host: host)

      assert result.success?
    end
  end
end
