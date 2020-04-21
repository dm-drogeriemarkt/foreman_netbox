# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Validate
          include ::Interactor

          def call
            return if context.host.compute_object&.cluster

            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid cluster attributes') % self.class
          end
        end
      end
    end
  end
end
