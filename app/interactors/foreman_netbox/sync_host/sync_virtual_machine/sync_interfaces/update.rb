# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Update
          include ::Interactor

          def call
            context.interfaces.each { |netbox_interface| update(netbox_interface) }
          end

          private

          def update(netbox_interface)
            old_params = old_params(netbox_interface)
            new_params = new_params(netbox_interface)
            return if old_params == new_params

            netbox_interface.update(new_params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          def old_params(netbox_interface)
            {
              mac_address: netbox_interface.mac_address
            }
          end

          def new_params(netbox_interface)
            host_interface = host_interface_for(netbox_interface)

            {
              mac_address: host_interface.mac
            }
          end

          def host_interface_for(netbox_interface)
            context.host.interfaces.find { |i| i.netbox_name == netbox_interface.name }
          end
        end
      end
    end
  end
end
