# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Validate
          include ::Interactor

          def call
            return if context.host.location&.name

            raise SyncHost::ValidationOrganizer::HostAttributeError, _('%s: Invalid site attributes') % self.class
          end
        end
      end
    end
  end
end
