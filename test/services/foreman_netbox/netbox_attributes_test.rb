# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class NetboxParametersTest < ActiveSupport::TestCase
    describe '#tenant' do
      let(:host) do
        FactoryBot.build_stubbed(
          :host,
          :managed,
          owner: FactoryBot.build_stubbed(:usergroup, name: expected[:name])
        )
      end

      let(:expected) do
        {
          name: 'Tenant Name',
          slug: 'tenant-name'
        }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:tenant) }
    end

    describe '#device' do
      let(:host) do
        FactoryBot.build_stubbed(:host, :managed, hostname: expected[:name]).tap do |host|
          host.stubs(:facts).returns({ serialnumber: expected[:serial] })
        end
      end

      let(:expected) do
        {
          name: 'device_name',
          serial: 'abc123'
        }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:device) }
    end

    describe '#device_role' do
      let(:host) { FactoryBot.build_stubbed(:host, :managed) }

      let(:expected) do
        { name: 'SERVER', color: '9e9e9e', slug: 'server' }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:device_role) }
    end

    describe '#device_type' do
      subject { host.netbox_facet.netbox_params.fetch(:device_type) }

      let(:host) do
        FactoryBot.build_stubbed(:host, :managed).tap do |host|
          host.stubs(:facts).returns({ productname: expected[:model] })
        end
      end

      let(:expected) do
        {
          model: 'Product Name',
          slug: 'product-name'
        }
      end

      it { assert_equal expected, subject }

      context 'unknown' do
        let(:host) { FactoryBot.build_stubbed(:host, :managed) }

        let(:expected) do
          {
            model: 'Unknown',
            slug: 'unknown'
          }
        end

        it { assert_equal expected, subject }
      end
    end

    describe '#manufacturer' do
      subject { host.netbox_facet.netbox_params.fetch(:manufacturer) }

      let(:host) do
        FactoryBot.build_stubbed(:host, :managed).tap do |host|
          host.stubs(:facts).returns({ manufacturer: expected[:name] })
        end
      end

      let(:expected) do
        { name: 'Manufacturer Name', slug: 'manufacturer-name' }
      end

      it { assert_equal expected, subject }

      context 'unknown' do
        let(:host) { FactoryBot.build_stubbed(:host, :managed) }

        let(:expected) do
          { name: 'Unknown', slug: 'unknown' }
        end

        it { assert_equal expected, subject }
      end
    end

    describe '#site' do
      let(:host) do
        FactoryBot.build_stubbed(
          :host,
          :managed,
          location: FactoryBot.build_stubbed(:location, name: expected[:name])
        )
      end

      let(:expected) do
        {
          name: 'Site Name',
          slug: 'site-name'
        }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:site) }
    end

    describe '#interfaces' do
      let(:host) do
        FactoryBot.build_stubbed(
          :host,
          :managed,
          interfaces: [
            FactoryBot.build_stubbed(
              :nic_base,
              identifier: expected.first[:name],
              mac: expected.first[:mac_address]
            )
          ]
        )
      end

      let(:expected) do
        [
          name: 'eth1',
          mac_address: 'FE:13:C6:44:29:24',
          type: {
            value: 'virtual'
          }
        ]
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:interfaces) }
    end

    describe '#ip_addresses' do
      let(:host) do
        FactoryBot.build_stubbed(
          :host,
          :managed,
          interfaces: [
            FactoryBot.build_stubbed(
              :nic_base,
              identifier: expected.first[:interface][:name],
              ip: expected.first[:address].split('/').first,
              subnet: FactoryBot.build_stubbed(
                :subnet_ipv4,
                cidr: expected.first[:address].split('/').second
              )
            ),
            FactoryBot.build_stubbed(
              :nic_base,
              identifier: expected.second[:interface][:name],
              ip6: expected.second[:address].split('/').first,
              subnet6: FactoryBot.build_stubbed(
                :subnet_ipv6,
                cidr: expected.second[:address].split('/').second
              )
            )
          ]
        )
      end

      let(:expected) do
        [
          {
            address: '10.0.0.1/24',
            interface: {
              name: 'eth1'
            }
          },
          {
            address: '1500:0:2d0:201::1/64',
            interface: {
              name: 'eth2'
            }
          }
        ]
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:ip_addresses) }
    end

    describe '#virtual_machine' do
      let(:host) do
        FactoryBot.build_stubbed(:host, :managed, hostname: expected[:name]).tap do |host|
          host.stubs(:compute?).returns(true)
          host.stubs(:compute_object).returns(
            OpenStruct.new(
              cpus: expected[:vcpus],
              memory_mb: expected[:memory],
              volumes: [
                OpenStruct.new(size_gb: expected[:disk] / 2),
                OpenStruct.new(size_gb: expected[:disk] / 2)
              ]
            )
          )
        end
      end

      let(:expected) do
        {
          name: 'virtual_machine_name',
          vcpus: 2,
          memory: 128,
          disk: 20
        }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:virtual_machine) }
    end

    describe '#cluster' do
      let(:host) do
        FactoryBot.build_stubbed(:host, :managed).tap do |host|
          host.stubs(:compute?).returns(true)
          host.stubs(:compute_object).returns(
            OpenStruct.new(cluster: expected[:name])
          )
        end
      end

      let(:expected) do
        { name: 'Cluster Name' }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:cluster) }
    end

    describe '#cluster_type' do
      let(:host) do
        FactoryBot.build_stubbed(:host, :managed).tap do |host|
          host.stubs(:compute?).returns(true)
          host.stubs(:compute_resource).returns(
            OpenStruct.new(type: 'Foreman::Model::Vmware')
          )
        end
      end

      let(:expected) do
        { name: 'VMware ESXi', slug: 'vmware-esxi' }
      end

      it { assert_equal expected, host.netbox_facet.netbox_params.fetch(:cluster_type) }
    end
  end
end
