# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Validate
          include ::Interactor
          include SyncDeviceType::Concerns::Productname

          def call
            return true if productname

            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid device type attributes') % self.class
          end
        end
      end
    end
  end
end
