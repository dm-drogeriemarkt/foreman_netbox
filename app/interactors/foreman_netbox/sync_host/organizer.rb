# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    class Organizer
      include ::Interactor::Organizer

      before do
        context.netbox_params = context.host.netbox_facet.netbox_params
        context.raw_data = {}
      end

      organize SyncHost::SyncVirtualMachine::Organizer,
        SyncHost::SyncDevice::Organizer

      def call
        super

        update_status
      rescue Interactor::Failure => e
        update_status
        raise e
      end

      private

      delegate :host, :error, to: :context
      delegate :netbox_facet, to: :host

      def update_status
        netbox_facet.update(synchronized_at: Time.zone.now, synchronization_error: error, raw_data: context.raw_data)
      end
    end
  end
end
