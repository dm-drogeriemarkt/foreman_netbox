# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Validate
            include ::Interactor
            include SyncManufacturer::Concerns::Manufacturer

            def call
              return true if manufacturer

              raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid manufacturer attributes') % self.class
            end
          end
        end
      end
    end
  end
end
