# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call if context.host.compute?
        end

        after do
          context.raw_data[:virtual_machine] = context.virtual_machine.raw_data!
        end

        organize SyncVirtualMachine::Validate,
          SyncHost::SyncTags::Organizer,
          SyncHost::SyncTenant::Organizer,
          SyncVirtualMachine::SyncCluster::Organizer,
          SyncVirtualMachine::Find,
          SyncVirtualMachine::Create,
          SyncVirtualMachine::SyncInterfaces::Organizer,
          SyncVirtualMachine::Update,
          SyncVirtualMachine::SaveNetboxURL
      end
    end
  end
end
