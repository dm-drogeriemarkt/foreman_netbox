# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Create
        include ::Interactor
        include ForemanNetbox::Concerns::AssignTags

        around do |interactor|
          interactor.call unless context.tenant
        end

        def call
          context.tenant = ForemanNetbox::Api.client::Tenancy::Tenant.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, to: :context

        def params
          netbox_params.fetch(:tenant)
                       .merge(tags: default_tag_ids)
                       .compact
        end
      end
    end
  end
end
