# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Create
          include ::Interactor

          TYPE = 'virtual'

          def call
            context.host
                   .interfaces
                   .reject { |host_interface| context.interfaces.map(&:name).include?(host_interface.name) }
                   .map do |host_interface|
                     ForemanNetbox::API.client::DCIM::Interface.new(
                       device: context.device.id,
                       name: host_interface.name,
                       mac_address: host_interface.mac,
                       type: TYPE
                     ).save
                   end
            context.interfaces.reload
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end
        end
      end
    end
  end
end
