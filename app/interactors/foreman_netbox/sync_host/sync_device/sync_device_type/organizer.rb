# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Organizer
          include ::Interactor::Organizer

          after do
            context.raw_data[:device_type] = context.device_type.raw_data!
          end

          organize SyncDeviceType::SyncManufacturer::Organizer,
            SyncDeviceType::Find,
            SyncDeviceType::Update,
            SyncDeviceType::Create
        end
      end
    end
  end
end
