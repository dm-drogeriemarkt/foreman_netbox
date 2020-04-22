# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Organizer
          include ::Interactor::Organizer

          around do |interactor|
            interactor.call if context.host.location
          end

          organize SyncSite::Find,
                   SyncSite::Create
        end
      end
    end
  end
end
