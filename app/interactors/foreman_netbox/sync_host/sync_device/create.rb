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
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :device_type, :device_role, :site, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def params
          {
            device_type: device_type.id,
            device_role: device_role.id,
            site: site.id,
            name: host.name,
            tenant: tenant&.id
          }
        end
      end
    end
  end
end
