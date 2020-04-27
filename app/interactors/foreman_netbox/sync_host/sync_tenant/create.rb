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

        delegate :netbox_tenant_name, :netbox_tenant_slug, to: :'context.host.owner'

        def params
          {
            name: netbox_tenant_name,
            slug: netbox_tenant_slug
          }
        end
      end
    end
  end
end
