# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Organizer
        include ::Interactor::Organizer

        around do |interactor|
          interactor.call unless context.host.compute?
        end

        after do
          context.raw_data[:device] = context.device.raw_data!
        end

        organize SyncDevice::Validate,
          SyncHost::SyncTags::Organizer,
          SyncHost::SyncTenant::Organizer,
          SyncDevice::SyncSite::Organizer,
          SyncDevice::SyncDeviceRole::Organizer,
          SyncDevice::SyncDeviceType::Organizer,
          SyncDevice::Find,
          SyncDevice::Create,
          SyncDevice::SyncInterfaces::Organizer,
          SyncDevice::Update,
          SyncDevice::SaveNetboxURL
      end
    end
  end
end
