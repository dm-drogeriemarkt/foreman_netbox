# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Find
        include ::Interactor

        def call
          # rubocop:disable Rails/DynamicFindBy
          context.device = find_by_serial || find_by_mac || find_by_name
          # rubocop:enable Rails/DynamicFindBy
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :host, to: :context
        delegate :name, :mac, :facts, to: :host

        def find_by_serial
          serial = facts&.symbolize_keys&.fetch(:serialnumber, nil)
          ForemanNetbox::API.client.dcim.devices.filter(serial: serial).first if serial
        end

        def find_by_mac
          ForemanNetbox::API.client.dcim.devices.filter(mac_address: mac).first if mac
        end

        def find_by_name
          ForemanNetbox::API.client.dcim.devices.find_by(name: name)
        end
      end
    end
  end
end
