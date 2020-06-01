# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        module SyncIpAddresses
          class Organizer
            include ::Interactor::Organizer

            organize SyncIpAddresses::Find,
                     SyncIpAddresses::Delete,
                     SyncIpAddresses::Update,
                     SyncIpAddresses::Create
          end
        end
      end
    end
  end
end
