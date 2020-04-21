# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateVirtualMachine
      module ValidateCluster
        class Validate
          include ::Interactor

          def call
            return if context.host.compute_object&.cluster

            context.fail!(error: _('%s: Invalid cluster attributes') % self.class)
          end
        end
      end
    end
  end
end
