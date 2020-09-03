# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Update
        include ::Interactor

        around do |interactor|
          interactor.call if context.tenant
        end

        def call
          new_tags = new_tenant_params.fetch(:tags, []) - tenant.tags
          tenant.tags = (tenant.tags | new_tags) if new_tags.any?

          tenant.save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :tenant, to: :context

        def new_tenant_params
          netbox_params.fetch(:tenant, {})
        end
      end
    end
  end
end
