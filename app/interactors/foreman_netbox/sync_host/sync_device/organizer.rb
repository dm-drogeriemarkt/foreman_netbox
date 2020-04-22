# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call unless context.host.compute?
        end

        organize SyncDevice::SyncSite::Organizer,
                 SyncDevice::SyncDeviceRole::Organizer,
                 SyncDevice::SyncDeviceType::Organizer,
                 SyncDevice::Find,
                 SyncDevice::Create,
                 SyncDevice::SyncInterfaces::Organizer,
                 SyncDevice::Update
      end
    end
  end
end
