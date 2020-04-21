# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        module SyncIpAddresses
          class Organizer
            include ::Interactor::Organizer

            organize SyncIpAddresses::Find,
                     SyncIpAddresses::Delete,
                     SyncIpAddresses::Create
          end
        end
      end
    end
  end
end
