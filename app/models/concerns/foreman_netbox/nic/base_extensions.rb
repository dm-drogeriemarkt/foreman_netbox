# frozen_string_literal: true

module ForemanNetbox
  module Nic
    module BaseExtensions
      def netbox_name
        identifier || (mac && "Interface #{mac}")
      end

      def netbox_ips
        [netbox_ip, netbox_ip6].compact
      end

      def netbox_ip
        ip && subnet && "#{ip}/#{subnet.cidr}"
      end

      def netbox_ip6
        ip6 && subnet6 && "#{ip6}/#{subnet6.cidr}"
      end
    end
  end
end
