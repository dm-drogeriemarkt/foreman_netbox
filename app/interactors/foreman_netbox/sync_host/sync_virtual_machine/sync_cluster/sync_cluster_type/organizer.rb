# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        module SyncClusterType
          class Organizer
            include ::Interactor::Organizer

            CLUSTER_TYPES = {
              :'Foreman::Model::Vmware' => {
                name: 'VMware ESXi',
                slug: 'vmware-esxi'
              }
            }.freeze

            organize SyncClusterType::Find,
                     SyncClusterType::Create
          end
        end
      end
    end
  end
end
