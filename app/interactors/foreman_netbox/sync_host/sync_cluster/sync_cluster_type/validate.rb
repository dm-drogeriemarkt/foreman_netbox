# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncCluster
      module SyncClusterType
        class Validate
          include ::Interactor

          def call
            type = context.host.compute_resource&.type&.to_sym
            return if SyncClusterType::Organizer::CLUSTER_TYPES.fetch(type, nil)

            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid cluster type attributes') % self.class
          end
        end
      end
    end
  end
end
