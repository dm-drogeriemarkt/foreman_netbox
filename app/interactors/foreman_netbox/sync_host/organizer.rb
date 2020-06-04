# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    class Organizer
      DEFAULT_TAGS = ['foreman'].freeze

      include ::Interactor::Organizer

      around do |interactor|
        begin
          validate
          interactor.call
          update_status
        rescue Interactor::Failure => e
          update_status
          raise e
        end
      end

      organize SyncHost::SyncTenant::Organizer,
               SyncHost::SyncVirtualMachine::Organizer,
               SyncHost::SyncDevice::Organizer

      private

      delegate :host, :error, to: :context
      delegate :netbox_facet, to: :host

      def validate
        validator = ForemanNetbox::ValidateHost::Organizer.call(host: context.host)
        context.fail!(error: validator.error) unless validator.success?
      end

      def update_status
        netbox_facet.update(synchronized_at: Time.zone.now, synchronization_error: error)
      end
    end
  end
end
