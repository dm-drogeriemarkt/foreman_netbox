# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      module ValidateDeviceType
        class Validate
          include ::Interactor
          include ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::Concerns::Productname

          def call
            return true if productname

            context.fail!(error: _('%s: Invalid device type attributes') % self.class)
          end
        end
      end
    end
  end
end
