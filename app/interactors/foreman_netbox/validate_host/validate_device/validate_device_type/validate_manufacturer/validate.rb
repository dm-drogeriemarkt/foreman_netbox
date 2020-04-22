# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      module ValidateDeviceType
        module ValidateManufacturer
          class Validate
            include ::Interactor
            include ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::SyncManufacturer::Concerns::Params

            def call
              return true if manufacturer

              context.fail!(error: _('%s: Invalid manufacturer attributes') % self.class)
            end
          end
        end
      end
    end
  end
end
