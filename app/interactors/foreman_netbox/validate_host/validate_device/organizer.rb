# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call unless context.host.compute?
        end

        organize ValidateHost::ValidateDevice::ValidateDeviceType::Organizer,
                 ValidateHost::ValidateDevice::ValidateSite::Validate
      end
    end
  end
end
