# frozen_string_literal: true

require 'test_plugin_helper'

class SyncRhelPhysicalHostTest < ActiveSupport::TestCase
  setup do
    setup_netbox_integration_test
  end

  subject { ForemanNetbox::SyncHost::Organizer.call(host: host) }

  let(:hostname) { 'rhel_physical_host' }
  let(:file) { file_fixture("facts/#{hostname}.json").read }
  let(:facts_json) { JSON.parse(file) }
  let(:host) do
    FactoryBot.build_stubbed(
      :host,
      hostname: "#{hostname}.tier.example.com",
      owner: FactoryBot.build_stubbed(:usergroup, name: SecureRandom.hex(16)),
      location: FactoryBot.build_stubbed(:location, name: 'Location'),
      interfaces: [
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth0',
          mac: 'C3:CD:63:54:21:61',
          ip: '10.0.0.8',
          subnet: FactoryBot.build_stubbed(:subnet_ipv4, organizations: [], locations: [])
        ),
        FactoryBot.build_stubbed(
          :nic_base,
          identifier: 'eth1',
          mac: '45:E9:6A:83:02:21',
          ip6: '1600:0:2d0:202::18',
          subnet6: FactoryBot.build_stubbed(:subnet_ipv6, organizations: [], locations: [])
        )
      ]
    ).tap do |host|
      host.stubs(:ip).returns(host.interfaces.find(&:ip).ip)
      host.stubs(:ip6).returns(host.interfaces.find(&:ip6).ip6)
      host.stubs(:compute?).returns(false)
      host.stubs(:facts).returns(facts_json)
    end
  end

  test 'sync host' do
    assert subject.success?

    assert_equal host.name,                         subject.device.name
    assert_equal host.owner.netbox_tenant_name,     subject.device.tenant.name
    assert_equal host.location.netbox_site_name,    subject.device.site.name
    assert_equal host.facts['manufacturer'],        subject.device.device_type.manufacturer.name
    assert_equal host.facts['productname'],         subject.device.device_type.model

    assert_equal IPAddress.parse("#{host.ip}/24"),  subject.device.primary_ip4.address
    assert_equal IPAddress.parse("#{host.ip6}/64"), subject.device.primary_ip6.address
    host.interfaces.each do |h_interface|
      nx_interface = subject.interfaces.find { |i| i.name == h_interface.identifier }

      assert nx_interface.present?

      h_interface.netbox_ips.each do |h_ip|
        assert subject.ip_addresses.find { |nx_ip| nx_ip.interface.id == nx_interface.id && nx_ip.address == IPAddress.parse(h_ip) }.present?
      end
    end
  end
end
