# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Find
        include ::Interactor

        def call
          context.tenant = ForemanNetbox::API.client.tenancy.tenants.find_by(params)
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, to: :context

        def params
          netbox_params.fetch(:tenant).slice(:slug)
        end
      end
    end
  end
end
