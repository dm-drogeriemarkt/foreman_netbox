# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Organizer
        include ::Interactor::Organizer

        organize SyncDevice::SyncSite::Organizer,
                 SyncDevice::SyncDeviceRole::Organizer,
                 SyncDevice::SyncDeviceType::Organizer,
                 SyncDevice::Find,
                 SyncDevice::Create,
                 SyncDevice::SyncInterfaces::Organizer,
                 SyncDevice::Update

        def call
          return if context.host.compute?

          super
        end
      end
    end
  end
end
