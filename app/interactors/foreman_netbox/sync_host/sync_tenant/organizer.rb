# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Organizer
        include ::Interactor::Organizer

        after do
          context.raw_data[:tenant] = context.tenant.raw_data!
        end

        organize SyncTenant::Find,
                 SyncTenant::Update,
                 SyncTenant::Create
      end
    end
  end
end
