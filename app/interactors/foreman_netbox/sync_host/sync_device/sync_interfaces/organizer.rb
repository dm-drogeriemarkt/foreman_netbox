# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Organizer
          include ::Interactor::Organizer

          organize SyncInterfaces::Find,
                   SyncInterfaces::Delete,
                   SyncInterfaces::Create,
                   SyncInterfaces::SyncIpAddresses::Organizer,
                   SyncInterfaces::Update
        end
      end
    end
  end
end
