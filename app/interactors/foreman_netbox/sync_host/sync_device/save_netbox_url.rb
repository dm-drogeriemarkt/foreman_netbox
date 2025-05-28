# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class SaveNetboxURL
        include ::Interactor

        around do |interactor|
          interactor.call if netbox_device_url != netbox_facet_url
        end

        def call
          netbox_facet.update(url: netbox_device_url)
        end

        private

        delegate :host, :device, to: :context
        delegate :netbox_facet, to: :host
        delegate :url, to: :netbox_facet, prefix: true, allow_nil: true

        def netbox_device_url
          "#{Setting[:netbox_url]}/dcim/devices/#{device&.id}" if device&.id
        end
      end
    end
  end
end
