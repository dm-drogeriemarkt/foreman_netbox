# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class SaveNetboxUrl
        include ::Interactor

        around do |interactor|
          interactor.call if netbox_virtual_machine_url != netbox_facet_url
        end

        def call
          netbox_facet.update(url: netbox_virtual_machine_url)
        end

        private

        delegate :host, to: :context
        delegate :url, to: :netbox_facet, prefix: true, allow_nil: true

        def netbox_virtual_machine_url
          return unless context.virtual_machine&.id

          "#{Setting::Netbox[:netbox_url]}/virtualization/virtual-machines/#{context.virtual_machine&.id}"
        end

        def netbox_facet
          @netbox_facet ||= ForemanNetbox::NetboxFacet.find_or_initialize_by(host_id: host.id)
        end
      end
    end
  end
end
