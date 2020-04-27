# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateVirtualMachine
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call if context.host.compute?
        end

        organize ValidateVirtualMachine::ValidateCluster::Organizer
      end
    end
  end
end
