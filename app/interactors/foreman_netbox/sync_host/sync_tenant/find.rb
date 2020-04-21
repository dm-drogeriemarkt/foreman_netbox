# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Find
        include ::Interactor

        def call
          context.tenant = ForemanNetbox::API.client.tenancy.tenants.find_by(params)
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            slug: context.host.owner.name.parameterize
          }
        end
      end
    end
  end
end
