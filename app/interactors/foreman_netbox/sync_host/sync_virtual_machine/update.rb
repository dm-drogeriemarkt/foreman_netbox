# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        ATTRIBUTES = %i[name cluster disk memory primary_ip4 primary_ip6 tenant vcpus tags].freeze

        around do |interactor|
          interactor.call if context.virtual_machine
        end

        before do
          context.ip_addresses.reload
        end

        def call
          assign_new_attributes

          virtual_machine.save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :virtual_machine, :cluster, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true
        delegate :compute_object, to: :host, allow_nil: true

        def assign_new_attributes
          ATTRIBUTES.map { |attribute| send("assign_#{attribute}") }
        end

        def assign_name
          virtual_machine.name = host.name if virtual_machine.name != host.name
        end

        def assign_cluster
          virtual_machine.cluster = cluster.id if virtual_machine.cluster.id != cluster.id
        end

        def assign_disk
          new_disk_value = compute_object&.volumes&.map(&:size_gb)&.reduce(&:+)
          virtual_machine.disk = new_disk_value if virtual_machine.disk != new_disk_value
        end

        def assign_memory
          virtual_machine.memory = compute_object&.memory_mb if virtual_machine.memory != compute_object&.memory_mb
        end

        def assign_primary_ip4
          virtual_machine.primary_ip4 = primary_ip4 if virtual_machine.primary_ip4&.id != primary_ip4
        end

        def assign_primary_ip6
          virtual_machine.primary_ip6 = primary_ip6 if virtual_machine.primary_ip6&.id != primary_ip6
        end

        def assign_tenant
          virtual_machine.tenant = tenant&.id if virtual_machine.tenant&.id != tenant&.id
        end

        def assign_vcpus
          virtual_machine.vcpus = compute_object&.cpus if virtual_machine.vcpus != compute_object&.cpus
        end

        def assign_tags
          default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
          return unless (default_tags - virtual_machine.tags).any?

          virtual_machine.tags = virtual_machine.tags | default_tags
        end
      end
    end
  end
end
