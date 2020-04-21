# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Delete
          include ::Interactor

          def call
            return if context.interfaces.total.zero?

            context.interfaces
                   .reject { |netbox_interface| context.host.interfaces.map(&:netbox_name).include?(netbox_interface.name) }
                   .each(&:delete)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end
        end
      end
    end
  end
end
