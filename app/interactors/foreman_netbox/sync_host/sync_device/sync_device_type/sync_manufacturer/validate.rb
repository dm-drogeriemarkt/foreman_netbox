# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Validate
            include ::Interactor

            def call
              context.host.facts.symbolize_keys.fetch(:'dmi::manufacturer')

              true
            rescue KeyError
              raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid manufacturer attributes') % self.class
            end
          end
        end
      end
    end
  end
end
