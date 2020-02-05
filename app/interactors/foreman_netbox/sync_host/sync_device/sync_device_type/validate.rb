# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Validate
          include ::Interactor

          def call
            context.host.facts.symbolize_keys.fetch(:'dmi::product::name')

            true
          rescue KeyError
            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid device type attributes') % self.class
          end
        end
      end
    end
  end
end
