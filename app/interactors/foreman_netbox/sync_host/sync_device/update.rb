# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        ATTRIBUTES = %i[name device_role device_type primary_ip4 primary_ip6 site tenant serial tags].freeze

        around do |interactor|
          interactor.call if context.device
        end

        before do
          context.ip_addresses.reload
        end

        def call
          assign_new_attributes

          device.save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :device, :device_type, :device_role, :site, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def new_device_params
          netbox_params.fetch(:device, {})
        end

        def assign_new_attributes
          ATTRIBUTES.map { |attribute| send("assign_#{attribute}") }
        end

        def assign_name
          device.name = new_device_params[:name] if device.name != new_device_params[:name]
        end

        def assign_device_role
          device.device_role = device_role&.id if device.device_role&.id != device_role&.id
        end

        def assign_device_type
          device.device_type = device_type&.id if device.device_type&.id != device_type&.id
        end

        def assign_primary_ip4
          device.primary_ip4 = primary_ip4 if device.primary_ip4&.id != primary_ip4
        end

        def assign_primary_ip6
          device.primary_ip6 = primary_ip6 if device.primary_ip6&.id != primary_ip6
        end

        def assign_site
          device.site = site&.id if device.site&.id != site&.id
        end

        def assign_tenant
          device.tenant = tenant&.id if device.tenant&.id != tenant&.id
        end

        def assign_serial
          new_serial = new_device_params[:serial]
          return if !new_serial || device.serial == new_serial

          device.serial = new_serial
        end

        def assign_tags
          new_tags = new_device_params.fetch(:tags, []) - device.tags

          device.tags = (device.tags | new_tags) if new_tags.any?
        end
      end
    end
  end
end
