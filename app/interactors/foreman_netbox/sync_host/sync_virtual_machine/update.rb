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
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :virtual_machine, :cluster, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def assign_new_attributes
          ATTRIBUTES.map { |attribute| send("assign_#{attribute}") }
        end

        def assign_name
          name = netbox_params.dig(:virtual_machine, :name)
          virtual_machine.name = name if virtual_machine.name != name
        end

        def assign_cluster
          virtual_machine.cluster = cluster.id if virtual_machine.cluster.id != cluster.id
        end

        def assign_disk
          disk = netbox_params.dig(:virtual_machine, :disk)
          virtual_machine.disk = disk if virtual_machine.disk != disk
        end

        def assign_memory
          memory = netbox_params.dig(:virtual_machine, :memory)
          virtual_machine.memory = memory if virtual_machine.memory != memory
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
          vcpus = netbox_params.dig(:virtual_machine, :vcpus)
          virtual_machine.vcpus = vcpus if virtual_machine.vcpus != vcpus
        end

        def assign_tags
          new_tags = (netbox_params.dig(:virtual_machine, :tags) || []) - virtual_machine.tags

          virtual_machine.tags = (virtual_machine.tags | new_tags) if new_tags.any?
        end
      end
    end
  end
end
