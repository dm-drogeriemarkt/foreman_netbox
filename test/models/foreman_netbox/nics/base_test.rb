# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  module Nic
    class BaseTest < ActiveSupport::TestCase
      describe '#netbox_name' do
        context 'with identifier' do
          let(:nic) { FactoryBot.build_stubbed(:nic_base, identifier: 'eth1') }

          it { assert_equal nic.identifier, nic.netbox_name }
        end

        context 'with mac' do
          let(:nic) { FactoryBot.build_stubbed(:nic_base, identifier: nil) }

          it { assert_equal "Interface #{nic.mac}", nic.netbox_name }
        end

        context 'without identifier and mac' do
          let(:nic) { FactoryBot.build_stubbed(:nic_base, identifier: nil, mac: nil) }

          it { assert_nil nic.netbox_name }
        end
      end

      describe '#netbox_ip' do
        let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4, mask: '255.255.0.0') }
        let(:nic) { FactoryBot.build_stubbed(:nic_base, ip: '10.10.10.0', subnet: subnet) }

        it { assert_equal '10.10.10.0/16', nic.netbox_ip }
      end

      describe '#netbox_ip6' do
        let(:subnet6) { FactoryBot.build_stubbed(:subnet_ipv6, mask: 'ffff:ffff::') }
        let(:nic) { FactoryBot.build_stubbed(:nic_base, ip6: '2001:db8::', subnet6: subnet6) }

        it { assert_equal '2001:db8::/32', nic.netbox_ip6 }
      end

      describe '#netbox_ips' do
        context 'with ip' do
          let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4) }
          let(:nic) { FactoryBot.build_stubbed(:nic_base, ip: '10.10.10.0', subnet: subnet) }

          it { assert_equal [nic.netbox_ip], nic.netbox_ips }
        end

        context 'with ip6' do
          let(:subnet6) { FactoryBot.build_stubbed(:subnet_ipv6) }
          let(:nic) { FactoryBot.build_stubbed(:nic_base, ip6: '2001:db8::', subnet6: subnet6) }

          it { assert_equal [nic.netbox_ip6], nic.netbox_ips }
        end

        context 'with ip and ip6' do
          let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4) }
          let(:subnet6) { FactoryBot.build_stubbed(:subnet_ipv6) }
          let(:nic) do
            FactoryBot.build_stubbed(
              :nic_base,
              ip: '10.10.10.0',
              ip6: '2001:db8::',
              subnet: subnet,
              subnet6: subnet6
            )
          end

          it { assert_equal [nic.netbox_ip, nic.netbox_ip6], nic.netbox_ips }
        end

        context 'without ip and ip6' do
          let(:nic) { FactoryBot.build_stubbed(:nic_base) }

          it { assert_equal [], nic.netbox_ips }
        end
      end
    end
  end
end
