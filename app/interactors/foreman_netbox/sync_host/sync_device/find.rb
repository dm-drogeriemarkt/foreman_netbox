# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Find
        include ::Interactor

        def call
          context.device = find_by_serial || find_by_mac || find_by_name
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :host, :netbox_params, to: :context
        delegate :mac, to: :host, allow_nil: true

        def find_by_serial
          serial = netbox_params.dig(:device, :serial)

          ForemanNetbox::API.client.dcim.devices.filter(serial: serial).first if serial
        end

        def find_by_mac
          ForemanNetbox::API.client.dcim.devices.filter(mac_address: mac).first if mac
        end

        def find_by_name
          name = netbox_params.dig(:device, :name)

          ForemanNetbox::API.client.dcim.devices.find_by(name: name)
        end
      end
    end
  end
end
