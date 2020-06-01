# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Create
        include ::Interactor

        around do |interactor|
          interactor.call unless context.virtual_machine
        end

        def call
          context.virtual_machine = ForemanNetbox::API.client::Virtualization::VirtualMachine.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :host, :cluster, to: :context
        delegate :tenant, to: :context, allow_nil: true
        delegate :compute_object, to: :host, allow_nil: true

        def params
          {
            name: host.name,
            cluster: cluster.id,
            tenant: tenant&.id,
            vcpus: compute_object&.cpus,
            memory: compute_object&.memory_mb,
            disk: compute_object&.volumes&.map(&:size_gb)&.reduce(&:+),
            tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
          }
        end
      end
    end
  end
end
