# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Validate
            include ::Interactor

            def call
              return if context.host.facts.deep_symbolize_keys.dig(:dmi, :manufacturer)

              raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid manufacturer attributes') % self.class
            end
          end
        end
      end
    end
  end
end
