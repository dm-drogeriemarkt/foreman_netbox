# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Update
        include ::Interactor

        def call
          return unless context.virtual_machine

          context.virtual_machine.update(new_params) if old_params != new_params
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def old_params
          {
            cluster: context.virtual_machine.cluster.id,
            tenant: context.virtual_machine.tenant&.id,
            vcpus: context.virtual_machine.vcpus,
            memory: context.virtual_machine.memory,
            disk: context.virtual_machine.disk,
            primary_ip4: context.virtual_machine.primary_ip4&.id,
            primary_ip6: context.virtual_machine.primary_ip6&.id
          }
        end

        def new_params
          {
            cluster: context.cluster.id,
            tenant: context.tenant&.id,
            vcpus: context.host.compute_object&.cpus,
            memory: context.host.compute_object&.memory_mb,
            disk: context.host.compute_object&.volumes&.map(&:size_gb)&.reduce(&:+),
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
