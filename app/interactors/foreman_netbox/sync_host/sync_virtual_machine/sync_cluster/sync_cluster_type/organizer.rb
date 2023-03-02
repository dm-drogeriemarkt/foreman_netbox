# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        module SyncClusterType
          class Organizer
            include ::Interactor::Organizer

            after do
              context.raw_data[:cluster_type] = context.cluster_type.raw_data!
            end

            organize SyncClusterType::Find,
              SyncClusterType::Create
          end
        end
      end
    end
  end
end
