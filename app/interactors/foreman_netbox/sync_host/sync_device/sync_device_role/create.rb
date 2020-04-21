# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Create
          include ::Interactor

          def call
            return if context.device_role

            context.device_role = ForemanNetbox::API.client::DCIM::DeviceRole.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            device_role_params = SyncDeviceRole::Organizer::DEVICE_ROLE

            {
              name: device_role_params[:name],
              slug: device_role_params[:name].parameterize,
              color: device_role_params[:color]
            }
          end
        end
      end
    end
  end
end
