# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Create
          include ::Interactor

          after do
            context.interfaces.reload
          end

          def call
            context.host
                   .interfaces
                   .reject { |host_interface| host_interface.netbox_name.blank? }
                   .reject { |host_interface| context.interfaces.map(&:name).include?(host_interface.netbox_name) }
                   .map do |host_interface|
                     ForemanNetbox::API.client::Virtualization::Interface.new(
                       virtual_machine: context.virtual_machine.id,
                       name: host_interface.netbox_name,
                       mac_address: host_interface.mac,
                       tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
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
