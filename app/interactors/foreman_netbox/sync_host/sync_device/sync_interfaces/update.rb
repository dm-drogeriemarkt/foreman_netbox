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

          delegate :netbox_params, to: :context

          def update(netbox_interface)
            new_params = netbox_params.fetch(:interfaces, [])
                                      .find { |i| i[:name] == netbox_interface.name }

            return unless new_params

            netbox_interface.mac_address = new_params[:mac_address] if netbox_interface.mac_address != new_params[:mac_address]

            new_tags = new_params.fetch(:tags, []) - netbox_interface.tags
            netbox_interface.tags = (netbox_interface.tags | new_tags) if new_tags.any?

            netbox_interface.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end
        end
      end
    end
  end
end
