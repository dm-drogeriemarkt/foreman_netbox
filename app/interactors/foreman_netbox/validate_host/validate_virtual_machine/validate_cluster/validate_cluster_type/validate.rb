# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateVirtualMachine
      module ValidateCluster
        module ValidateClusterType
          class Validate
            include ::Interactor

            def call
              type = context.host.compute_resource&.type&.to_sym
              return if ForemanNetbox::SyncHost::SyncVirtualMachine::SyncCluster::SyncClusterType::Organizer::CLUSTER_TYPES.fetch(type, nil)

              context.fail!(error: _('%s: Invalid cluster type attributes') % self.class)
            end
          end
        end
      end
    end
  end
end
