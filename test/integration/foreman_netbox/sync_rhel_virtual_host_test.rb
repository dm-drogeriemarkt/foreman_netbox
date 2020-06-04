# frozen_string_literal: true

require 'test_plugin_helper'

class SyncRhelVirtualHostTest < ActiveSupport::TestCase
  setup do
    setup_netbox_integration_test
  end

  subject { ForemanNetbox::SyncHost::Organizer.call(host: host) }

  let(:hostname) { 'rhel_virtual_host' }
  let(:file) { file_fixture("facts/#{hostname}.json").read }
  let(:facts_json) { JSON.parse(file) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      hostname: "#{hostname}.tier.example.com",
      owner: FactoryBot.build_stubbed(:usergroup, name: 'Owner'),
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth0',
          mac: 'C3:CD:63:54:21:62',
          ip: '10.0.0.9',
          subnet: FactoryBot.build_stubbed(:subnet_ipv4, organizations: [], locations: [])
        ),
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth1',
          mac: '45:E9:6A:83:02:22',
          ip6: '1600:0:2d0:202::19',
          subnet6: FactoryBot.build_stubbed(:subnet_ipv6, organizations: [], locations: [])
        )
      ]
    ).tap do |host|
      host.stubs(:ip).returns(host.interfaces.find(&:ip).ip)
      host.stubs(:ip6).returns(host.interfaces.find(&:ip6).ip6)
      host.stubs(:compute?).returns(true)
      host.stubs(:compute_resource).returns(
        OpenStruct.new(type: 'Foreman::Model::Vmware')
      )
      host.stubs(:compute_object).returns(
        OpenStruct.new(
          cluster: 'CLUSTER',
          cpus: 1,
          memory_mb: 1024,
          volumes: [
            OpenStruct.new(size_gb: 120)
          ]
        )
      )
      host.stubs(:facts).returns(facts_json)
    end
  end

  test 'sync host' do
    ForemanNetbox::NetboxFacet.any_instance.expects(:update).twice.returns(true)

    assert subject.success?

    assert_equal host.name,                                 subject.virtual_machine.name
    assert_equal host.owner.netbox_tenant_name,             subject.virtual_machine.tenant.name
    assert_equal host.compute_object.cpus,                  subject.virtual_machine.vcpus
    assert_equal host.compute_object.memory_mb,             subject.virtual_machine.memory
    assert_equal host.compute_object.volumes.first.size_gb, subject.virtual_machine.disk
    assert_equal host.compute_object.cluster,               subject.virtual_machine.cluster.name
    assert_equal 'VMware ESXi',                             subject.cluster_type.name

    assert_equal IPAddress.parse("#{host.ip}/24"),  subject.virtual_machine.primary_ip4.address
    assert_equal IPAddress.parse("#{host.ip6}/64"), subject.virtual_machine.primary_ip6.address
    host.interfaces.each do |h_interface|
      nx_interface = subject.interfaces.find { |i| i.name == h_interface.identifier }

      assert nx_interface.present?

      h_interface.netbox_ips.each do |h_ip|
        assert subject.ip_addresses.find { |nx_ip| nx_ip.interface.id == nx_interface.id && nx_ip.address == IPAddress.parse(h_ip) }.present?
      end
    end

    expected_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
    assert_equal expected_tags, subject.virtual_machine.tags
    assert_equal expected_tags, subject.tenant.tags
    assert_equal expected_tags, subject.cluster.tags
    subject.interfaces.reload.each do |interface|
      assert_equal expected_tags, interface.tags
    end
    subject.ip_addresses.reload.each do |interface|
      assert_equal expected_tags, interface.tags
    end
  end
end
