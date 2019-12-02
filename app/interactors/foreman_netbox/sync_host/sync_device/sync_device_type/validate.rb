# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Validate
          include ::Interactor

          def call
            return if context.host.facts.deep_symbolize_keys.dig(:dmi, :product, :name)

            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid device type attributes') % self.class
          end
        end
      end
    end
  end
end
