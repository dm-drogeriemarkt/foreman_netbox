# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateVirtualMachine
      module ValidateCluster
        class Organizer
          include ::Interactor::Organizer

          organize ValidateCluster::ValidateClusterType::Validate,
                   ValidateCluster::Validate
        end
      end
    end
  end
end
