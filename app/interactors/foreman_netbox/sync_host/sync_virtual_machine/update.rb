# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        around do |interactor|
          interactor.call if context.virtual_machine
        end

        before do
          context.ip_addresses.reload
        end

        def call
          virtual_machine.update(new_params) if old_params != new_params
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :virtual_machine, :cluster, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true
        delegate :compute_object, to: :host, allow_nil: true

        def old_params
          {
            cluster: virtual_machine.cluster.id,
            disk: virtual_machine.disk,
            memory: virtual_machine.memory,
            primary_ip4: virtual_machine.primary_ip4&.id,
            primary_ip6: virtual_machine.primary_ip6&.id,
            tenant: virtual_machine.tenant&.id,
            vcpus: virtual_machine.vcpus,
            tags: virtual_machine.tags
          }
        end

        def new_params
          {
            cluster: cluster.id,
            disk: compute_object&.volumes&.map(&:size_gb)&.reduce(&:+),
            memory: compute_object&.memory_mb,
            primary_ip4: primary_ip4,
            primary_ip6: primary_ip6,
            tenant: tenant&.id,
            vcpus: compute_object&.cpus,
            tags: virtual_machine.tags | ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
          }
        end
      end
    end
  end
end
