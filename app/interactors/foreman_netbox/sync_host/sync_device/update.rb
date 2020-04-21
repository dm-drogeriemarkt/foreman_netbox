# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        def call
          return unless context.device

          context.device.update(new_params) if old_params != new_params
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def old_params
          {
            device_role: context.device.device_role.id,
            device_type: context.device.device_type.id,
            primary_ip4: context.device.primary_ip4&.id,
            primary_ip6: context.device.primary_ip6&.id,
            site: context.device.site.id,
            tenant: context.device.tenant&.id
          }
        end

        def new_params
          {
            device_role: context.device_role.id,
            device_type: context.device_type.id,
            primary_ip4: primary_ip4,
            primary_ip6: primary_ip6,
            site: context.site.id,
            tenant: context.tenant&.id
          }
        end
      end
    end
  end
end
