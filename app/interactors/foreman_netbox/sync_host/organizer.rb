# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    class Organizer
      include ::Interactor::Organizer

      before :validate

      organize SyncHost::SyncTenant::Organizer,
               SyncHost::SyncVirtualMachine::Organizer,
               SyncHost::SyncDevice::Organizer

      private

      def validate
        validator = ForemanNetbox::ValidateHost::Organizer.call(host: context.host)
        context.fail!(error: validator.error) unless validator.success?
      end
    end
  end
end
