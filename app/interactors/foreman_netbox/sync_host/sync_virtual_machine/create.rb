# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Create
        include ::Interactor
        include ForemanNetbox::Concerns::AssignTags

        around do |interactor|
          interactor.call unless context.virtual_machine
        end

        def call
          context.virtual_machine = ForemanNetbox::API.client::Virtualization::VirtualMachine.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :cluster, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def params
          netbox_params.fetch(:virtual_machine).merge(
            cluster: cluster.id,
            tenant: tenant&.id,
            tags: default_tag_ids
          ).compact
        end
      end
    end
  end
end
