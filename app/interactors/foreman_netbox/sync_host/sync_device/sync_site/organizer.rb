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

          after do
            context.raw_data[:site] = context.site.raw_data!
          end

          organize SyncSite::Find,
            SyncSite::Update,
            SyncSite::Create
        end
      end
    end
  end
end
