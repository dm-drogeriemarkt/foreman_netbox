# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        module SyncIpAddresses
          class Organizer
            include ::Interactor::Organizer

            after do
              context.raw_data[:ip_addresses] = context.ip_addresses.reload.raw_data!
            end

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
