# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Organizer
          include ::Interactor::Organizer

          after do
            context.raw_data[:cluster] = context.cluster.raw_data!
          end

          organize SyncCluster::SyncClusterType::Organizer,
            SyncCluster::Find,
            SyncCluster::Update,
            SyncCluster::Create
        end
      end
    end
  end
end
