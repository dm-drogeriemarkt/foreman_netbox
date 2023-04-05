# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Find
          include ::Interactor

          def call
            context.interfaces = ForemanNetbox::API.client.dcim.interfaces.filter(params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :device, to: :context

          def params
            {
              device_id: device.id,
            }
          end
        end
      end
    end
  end
end
