# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Create
        include ::Interactor

        def call
          return if context.device

          context.device = ForemanNetbox::API.client::DCIM::Device.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            device_type: context.device_type.id,
            device_role: context.device_role.id,
            site: context.site.id,
            name: context.host.name,
            cluster: context.cluster&.id,
            tenant: context.tenant&.id
          }
        end
      end
    end
  end
end
