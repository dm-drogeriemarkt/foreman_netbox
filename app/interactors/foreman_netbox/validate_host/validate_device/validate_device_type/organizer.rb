# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      module ValidateDeviceType
        class Organizer
          include ::Interactor::Organizer

          organize ValidateDeviceType::ValidateManufacturer::Validate,
                   ValidateDeviceType::Validate
        end
      end
    end
  end
end
