# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Update
        include ::Interactor

        def call
          return unless context.device

          context.device.update(new_params) if old_params != new_params
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def old_params
          {
            device_type: context.device.device_type.id,
            device_role: context.device.device_role.id,
            site: context.device.site.id,
            cluster: context.device.cluster&.symbolize_keys&.fetch(:id),
            tenant: context.device.tenant&.id,
            primary_ip4: context.device.primary_ip4&.id,
            primary_ip6: context.device.primary_ip6&.id
          }
        end

        def new_params
          {
            device_type: context.device_type.id,
            device_role: context.device_role.id,
            site: context.site.id,
            cluster: context.cluster&.id,
            tenant: context.tenant&.id,
            primary_ip4: primary_ip4,
            primary_ip6: primary_ip6
          }
        end

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
            key = IPAddr.new(ip.address.address).to_i
            hash[key] = ip.id
          end
        end
      end
    end
  end
end
