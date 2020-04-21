# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

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
            disk: context.virtual_machine.disk,
            memory: context.virtual_machine.memory,
            primary_ip4: context.virtual_machine.primary_ip4&.id,
            primary_ip6: context.virtual_machine.primary_ip6&.id,
            tenant: context.virtual_machine.tenant&.id,
            vcpus: context.virtual_machine.vcpus
          }
        end

        def new_params
          {
            cluster: context.cluster.id,
            disk: context.host.compute_object&.volumes&.map(&:size_gb)&.reduce(&:+),
            memory: context.host.compute_object&.memory_mb,
            primary_ip4: primary_ip4,
            primary_ip6: primary_ip6,
            tenant: context.tenant&.id,
            vcpus: context.host.compute_object&.cpus
          }
        end
      end
    end
  end
end
