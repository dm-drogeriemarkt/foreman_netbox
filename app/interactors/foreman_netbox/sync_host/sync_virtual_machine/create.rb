# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Create
        include ::Interactor

        def call
          return if context.virtual_machine

          context.virtual_machine = ForemanNetbox::API.client::Virtualization::VirtualMachine.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            name: context.host.name,
            cluster: context.cluster.id,
            tenant: context.tenant&.id,
            vcpus: context.host.compute_object&.cpus,
            memory: context.host.compute_object&.memory_mb,
            disk: context.host.compute_object&.volumes&.map(&:size_gb)&.reduce(&:+)
          }
        end
      end
    end
  end
end
