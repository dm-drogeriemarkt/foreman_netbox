# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Organizer
          include ::Interactor::Organizer

          after do
            context.raw_data[:interfaces] = context.interfaces.reload.raw_data!
          end

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
