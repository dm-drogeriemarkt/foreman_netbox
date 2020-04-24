# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        around do |interactor|
          interactor.call if context.device
        end

        before do
          context.ip_addresses.reload
        end

        def call
          context.device.update(new_params) if old_params != new_params
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :device, :device_type, :device_role, :site, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true
        delegate :facts, to: :host

        def old_params
          {
            device_role: device.device_role.id,
            device_type: device.device_type.id,
            primary_ip4: device.primary_ip4&.id,
            primary_ip6: device.primary_ip6&.id,
            site: device.site.id,
            tenant: device.tenant&.id,
            serial: device.serial
          }
        end

        def new_params
          {
            device_role: device_role.id,
            device_type: device_type.id,
            primary_ip4: primary_ip4,
            primary_ip6: primary_ip6,
            site: site.id,
            tenant: tenant&.id,
            serial: facts&.symbolize_keys&.fetch(:serialnumber, nil)
          }
        end
      end
    end
  end
end
