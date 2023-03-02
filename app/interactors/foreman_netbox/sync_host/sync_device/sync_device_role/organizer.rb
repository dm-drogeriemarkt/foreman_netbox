# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Organizer
          include ::Interactor::Organizer

          after do
            context.raw_data[:device_role] = context.device_role.raw_data!
          end

          organize SyncDeviceRole::Find,
            SyncDeviceRole::Create
        end
      end
    end
  end
end
