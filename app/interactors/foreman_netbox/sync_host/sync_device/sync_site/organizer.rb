# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Organizer
          include ::Interactor::Organizer

          organize SyncSite::Find,
                   SyncSite::Create

          def call
            return unless context.host.location

            super
          end
        end
      end
    end
  end
end
