# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class ValidationOrganizer
        include ::Interactor::Organizer

        organize SyncHost::SyncCluster::ValidationOrganizer

        def call
          return unless context.host.compute?

          super
        end
      end
    end
  end
end
