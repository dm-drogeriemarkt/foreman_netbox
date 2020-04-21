# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Create
        include ::Interactor

        def call
          return if context.tenant

          context.tenant = ForemanNetbox::API.client::Tenancy::Tenant.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          tenant_name = context.host.owner.name

          {
            name: tenant_name,
            slug: tenant_name.parameterize
          }
        end
      end
    end
  end
end
