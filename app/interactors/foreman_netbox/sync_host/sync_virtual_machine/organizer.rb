# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Organizer
        include ::Interactor::Organizer

        organize SyncVirtualMachine::Find,
                 SyncVirtualMachine::Create,
                 SyncVirtualMachine::SyncInterfaces::Organizer,
                 SyncVirtualMachine::Update

        def call
          return unless context.host.compute?

          super
        end
      end
    end
  end
end
