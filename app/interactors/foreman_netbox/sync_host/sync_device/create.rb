# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Create
        include ::Interactor

        around do |interactor|
          interactor.call unless context.device
        end

        def call
          context.device = ForemanNetbox::API.client::DCIM::Device.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :device_type, :device_role, :site, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def params
          netbox_params.fetch(:device).merge(
            device_type: device_type.id,
            device_role: device_role.id,
            site: site.id,
            tenant: tenant&.id
          ).compact
        end
      end
    end
  end
end
