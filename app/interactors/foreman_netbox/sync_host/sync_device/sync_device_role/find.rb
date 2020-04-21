# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Find
          include ::Interactor

          def call
            context.device_role = ForemanNetbox::API.client.dcim.device_roles.find_by(params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            {
              slug: SyncDeviceRole::Organizer::DEVICE_ROLE.fetch(:name).parameterize
            }
          end
        end
      end
    end
  end
end
