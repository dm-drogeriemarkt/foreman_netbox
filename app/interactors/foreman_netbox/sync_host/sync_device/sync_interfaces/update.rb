# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Update
          include ::Interactor

          def call
            context.interfaces.each { |netbox_interface| update(netbox_interface) }
          end

          private

          def update(netbox_interface)
            host_interface = host_interface_for(netbox_interface)

            return unless host_interface

            changed = false

            if netbox_interface.mac_address != host_interface.mac
              netbox_interface.mac_address = host_interface.mac
              changed = true
            end

            netbox_interface.save if changed
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          def host_interface_for(netbox_interface)
            context.host.interfaces.find { |i| i.netbox_name == netbox_interface.name }
          end
        end
      end
    end
  end
end
