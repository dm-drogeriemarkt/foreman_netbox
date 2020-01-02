# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class SaveNetboxUrl
        include ::Interactor

        around do |interactor|
          interactor.call if netbox_device_url != netbox_facet_url
        end

        def call
          netbox_facet.update(url: netbox_device_url)
        end

        private

        delegate :host, to: :context
        delegate :url, to: :netbox_facet, prefix: true, allow_nil: true

        def netbox_device_url
          return unless context.device&.id

          "#{Setting::Netbox[:netbox_url]}/dcim/devices/#{context.device&.id}"
        end

        def netbox_facet
          @netbox_facet ||= ForemanNetbox::NetboxFacet.find_or_initialize_by(host_id: host.id)
        end
      end
    end
  end
end
