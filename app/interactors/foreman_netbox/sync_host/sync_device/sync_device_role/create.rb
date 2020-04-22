# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Create
          include ::Interactor
          include SyncDeviceRole::Concerns::Params

          around do |interactor|
            interactor.call unless context.device_role
          end

          def call
            context.device_role = ForemanNetbox::API.client::DCIM::DeviceRole.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            {
              name: name,
              slug: slug,
              color: color
            }
          end
        end
      end
    end
  end
end
