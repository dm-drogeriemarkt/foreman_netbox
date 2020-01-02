# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call if context.host.compute?
        end

        organize SyncVirtualMachine::SyncCluster::Organizer,
                 SyncVirtualMachine::Find,
                 SyncVirtualMachine::Create,
                 SyncVirtualMachine::SyncInterfaces::Organizer,
                 SyncVirtualMachine::Update,
                 SyncVirtualMachine::SaveNetboxUrl
      end
    end
  end
end
