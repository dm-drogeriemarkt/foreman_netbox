# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class NetboxFacetTest < ActiveSupport::TestCase
    describe '#netbox_will_change?' do
      let(:tenant_name) { raw_data.dig(:tenant, :name) }
      let(:interfaces) { raw_data.dig(:interfaces, :results) }
      let(:ip_addresses) { raw_data.dig(:ip_addresses, :results) }

      context 'when the host is a device' do
        let(:raw_data) { JSON.parse(file_fixture('netbox_device_raw_data.json').read).deep_symbolize_keys }
        let(:device_name) { raw_data.dig(:device, :name) }
        let(:site_name) { raw_data.dig(:site, :name) }
        let(:device_serial) { raw_data.dig(:device, :serial) }
        let(:manufacturer_name) { raw_data.dig(:manufacturer, :name) }
        let(:device_type_model) { raw_data.dig(:device_type, :model) }
        let(:host) do
          FactoryBot.build_stubbed(
            :host,
            :managed,
            :with_device_netbox_facet,
            hostname: device_name,
            owner: FactoryBot.build_stubbed(:usergroup, name: tenant_name),
            location: FactoryBot.build_stubbed(:location, name: site_name),
            interfaces: interfaces.map do |interface|
              ip4 = ip_addresses.find do |ip|
                ip[:interface][:name] == interface[:name] && ip[:family][:value] == 4
              end
              ip6 = ip_addresses.find do |ip|
                ip[:interface][:name] == interface[:name] && ip[:family][:value] == 6
              end

              FactoryBot.build_stubbed(
                :nic_base,
                identifier: interface[:name],
                mac: interface[:mac_address],
                ip: ip4 && ip4[:address].split('/').first,
                subnet: ip4 && FactoryBot.build_stubbed(
                  :subnet_ipv4,
                  cidr: ip4[:address].split('/').second
                ),
                ip6: ip6 && ip6[:address].split('/').first,
                subnet6: ip6 && FactoryBot.build_stubbed(
                  :subnet_ipv6,
                  cidr: ip6[:address].split('/').second
                )
              )
            end
          ).tap do |host|
            host.stubs(:compute?).returns(false)
            host.stubs(:facts).returns(
              serialnumber: device_serial,
              manufacturer: manufacturer_name,
              productname: device_type_model
            )
          end
        end

        context 'when no changes detected' do
          it { assert_not host.netbox_facet.netbox_will_change? }
        end

        context 'when interfaces are changed' do
          let(:interfaces) { [] }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when ip_addresses are changed' do
          let(:ip_addresses) { [] }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when tenant is changed' do
          let(:tenant_name) { 'New Tenant Name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when device is changed' do
          let(:device_name) { 'new_device_name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when device type is changed' do
          let(:device_type_model) { 'New Device Type Model' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when manufacturer is changed' do
          let(:manufacturer_name) { 'New Manufacturer Name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when manufacturer is changed' do
          let(:site_name) { 'New Site Name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end
      end

      context 'when the host is a virtual machine' do
        let(:raw_data) { JSON.parse(file_fixture('netbox_virtual_machine_raw_data.json').read).deep_symbolize_keys }
        let(:virtual_machine_name) { raw_data.dig(:virtual_machine, :name) }
        let(:cluster_name) { raw_data.dig(:cluster, :name) }
        let(:vcpus) { raw_data.dig(:virtual_machine, :vcpus) }
        let(:memory) { raw_data.dig(:virtual_machine, :memory) }
        let(:disk) { raw_data.dig(:virtual_machine, :disk) }
        let(:host) do
          FactoryBot.build_stubbed(
            :host,
            :managed,
            :with_virtual_machine_netbox_facet,
            hostname: virtual_machine_name,
            owner: FactoryBot.build_stubbed(:usergroup, name: tenant_name),
            interfaces: interfaces.map do |interface|
              ip4 = ip_addresses.find do |ip|
                ip[:interface][:name] == interface[:name] && ip[:family][:value] == 4
              end
              ip6 = ip_addresses.find do |ip|
                ip[:interface][:name] == interface[:name] && ip[:family][:value] == 6
              end

              FactoryBot.build_stubbed(
                :nic_base,
                identifier: interface[:name],
                mac: interface[:mac_address],
                ip: ip4 && ip4[:address].split('/').first,
                subnet: ip4 && FactoryBot.build_stubbed(
                  :subnet_ipv4,
                  cidr: ip4[:address].split('/').second
                ),
                ip6: ip6 && ip6[:address].split('/').first,
                subnet6: ip6 && FactoryBot.build_stubbed(
                  :subnet_ipv6,
                  cidr: ip6[:address].split('/').second
                )
              )
            end
          ).tap do |host|
            host.stubs(:compute?).returns(true)
            host.stubs(:compute_object).returns(
              OpenStruct.new(
                cluster: cluster_name,
                cpus: vcpus,
                memory_mb: memory,
                volumes: [
                  OpenStruct.new(size_gb: disk / 2),
                  OpenStruct.new(size_gb: disk / 2)
                ]
              )
            )
            host.stubs(:compute_resource).returns(
              OpenStruct.new(type: 'Foreman::Model::Vmware')
            )
          end
        end

        context 'when no changes detected' do
          it { assert_not host.netbox_facet.netbox_will_change? }
        end

        context 'when interfaces are changed' do
          let(:interfaces) { [] }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when ip_addresses are changed' do
          let(:ip_addresses) { [] }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when tenant is changed' do
          let(:tenant_name) { 'New Tenant Name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when virtual machine is changed' do
          let(:virtual_machine_name) { 'new_virtual_machine' }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when cpus is changed' do
          let(:vcpus) { raw_data.dig(:virtual_machine, :vcpus) * 2 }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when memory is changed' do
          let(:memory) { raw_data.dig(:virtual_machine, :memory) * 2 }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when disk is changed' do
          let(:disk) { raw_data.dig(:virtual_machine, :disk) * 2 }

          it { assert host.netbox_facet.netbox_will_change? }
        end

        context 'when cluster is changed' do
          let(:cluster_name) { 'New Cluster Name' }

          it { assert host.netbox_facet.netbox_will_change? }
        end
      end
    end
  end
end
