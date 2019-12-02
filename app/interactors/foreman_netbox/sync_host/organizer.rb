# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    class Organizer
      include ::Interactor::Organizer

      organize SyncHost::ValidationOrganizer,
               SyncHost::SyncTenant::Organizer,
               SyncHost::SyncCluster::Organizer,
               SyncHost::SyncVirtualMachine::Organizer,
               SyncHost::SyncDevice::Organizer
    end
  end
end
