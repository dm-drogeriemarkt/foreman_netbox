# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    class ValidationOrganizer
      include ::Interactor::Organizer

      organize SyncHost::SyncDevice::ValidationOrganizer,
               SyncHost::SyncVirtualMachine::ValidationOrganizer

      def call
        super
      rescue HostAttributeError => e
        Foreman::Logging.exception(e.message, e)
        context.fail!(error: e.message)
      end

      class HostAttributeError < StandardError; end
    end
  end
end
