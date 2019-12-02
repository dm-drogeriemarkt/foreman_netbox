# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Organizer
            include ::Interactor::Organizer

            organize SyncManufacturer::Find,
                     SyncManufacturer::Create
          end
        end
      end
    end
  end
end
