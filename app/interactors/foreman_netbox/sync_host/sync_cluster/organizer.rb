# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncCluster
      class Organizer
        include ::Interactor::Organizer

        organize SyncCluster::SyncClusterType::Organizer,
                 SyncCluster::Find,
                 SyncCluster::Create
      end
    end
  end
end
