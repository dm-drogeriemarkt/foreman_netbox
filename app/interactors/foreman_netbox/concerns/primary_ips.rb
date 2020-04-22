# frozen_string_literal: true

module ForemanNetbox
  module Concerns
    module PrimaryIps
      def primary_ip4
        return if context.host.ip.blank?

        ip_addresses_map[IPAddr.new(context.host.ip).to_i]
      end

      def primary_ip6
        return if context.host.ip6.blank?

        ip_addresses_map[IPAddr.new(context.host.ip6).to_i]
      end

      def ip_addresses_map
        @ip_addresses_map ||= context.ip_addresses.each_with_object({}) do |ip, hash|
          hash[ip.address.to_i] = ip.id
        end
      end
    end
  end
end
