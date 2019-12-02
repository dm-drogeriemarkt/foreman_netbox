# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Organizer
        include ::Interactor::Organizer

        organize SyncTenant::Find,
                 SyncTenant::Create
      end
    end
  end
end
