# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Create
          include ::Interactor

          TYPE = 'virtual'

          after do
            context.interfaces.reload
          end

          def call
            context.host
                   .interfaces
                   .reject { |host_interface| host_interface.netbox_name.blank? }
                   .reject { |host_interface| context.interfaces.map(&:name).include?(host_interface.netbox_name) }
                   .map do |host_interface|
                     ForemanNetbox::API.client::DCIM::Interface.new(
                       device: context.device.id,
                       name: host_interface.netbox_name,
                       mac_address: host_interface.mac,
                       type: TYPE
                     ).save
                   end
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end
        end
      end
    end
  end
end
