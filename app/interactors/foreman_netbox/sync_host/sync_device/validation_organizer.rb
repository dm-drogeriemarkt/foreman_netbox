# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class ValidationOrganizer
        include ::Interactor::Organizer

        organize SyncHost::SyncDevice::SyncDeviceType::ValidationOrganizer,
                 SyncHost::SyncDevice::SyncSite::Validate

        def call
          return if context.host.compute?

          super
        end
      end
    end
  end
end
