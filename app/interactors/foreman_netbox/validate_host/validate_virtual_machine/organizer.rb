# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateVirtualMachine
      class Organizer
        include ::Interactor::Organizer

        organize ValidateVirtualMachine::ValidateCluster::Organizer

        def call
          return unless context.host.compute?

          super
        end
      end
    end
  end
end
