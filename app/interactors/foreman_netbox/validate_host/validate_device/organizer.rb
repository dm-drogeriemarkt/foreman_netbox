# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      class Organizer
        include ::Interactor::Organizer

        organize ValidateHost::ValidateDevice::ValidateDeviceType::Organizer,
                 ValidateHost::ValidateDevice::ValidateSite::Validate

        def call
          return if context.host.compute?

          super
        end
      end
    end
  end
end
