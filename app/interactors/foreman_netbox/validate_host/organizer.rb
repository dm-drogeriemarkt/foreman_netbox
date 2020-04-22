# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    class Organizer
      include ::Interactor::Organizer

      organize ValidateHost::ValidateDevice::Organizer,
               ValidateHost::ValidateVirtualMachine::Organizer
    end
  end
end
