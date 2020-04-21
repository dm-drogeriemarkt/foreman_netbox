# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class ValidationOrganizer
          include ::Interactor::Organizer

          organize SyncDeviceType::SyncManufacturer::Validate,
                   SyncDeviceType::Validate
        end
      end
    end
  end
end
