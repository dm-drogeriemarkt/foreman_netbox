# frozen_string_literal: true

module ForemanNetbox
  module DeleteHost
    class Organizer
      include ::Interactor::Organizer

      organize DeleteHost::DeleteVirtualMachine,
        DeleteHost::DeleteDevice
    end
  end
end
