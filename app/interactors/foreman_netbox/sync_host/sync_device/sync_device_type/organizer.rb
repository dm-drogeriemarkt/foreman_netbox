# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Organizer
          include ::Interactor::Organizer

          organize SyncDeviceType::SyncManufacturer::Organizer,
                   SyncDeviceType::Find,
                   SyncDeviceType::Create
        end
      end
    end
  end
end
