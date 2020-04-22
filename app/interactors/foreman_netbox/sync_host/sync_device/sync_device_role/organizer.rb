# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Organizer
          include ::Interactor::Organizer

          organize SyncDeviceRole::Find,
                   SyncDeviceRole::Create
        end
      end
    end
  end
end
