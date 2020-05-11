# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Update
        include ::Interactor
        include ForemanNetbox::Concerns::PrimaryIps

        ATTRIBUTES = %i[device_role device_type primary_ip4 primary_ip6 site tenant serial].freeze

        around do |interactor|
          interactor.call if context.device
        end

        before do
          context.ip_addresses.reload
        end

        def call
          assign_new_attributes

          context.device.save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :device, :device_type, :device_role, :site, :host, to: :context
        delegate :tenant, to: :context, allow_nil: true
        delegate :facts, to: :host

        def assign_new_attributes
          ATTRIBUTES.map { |attribute| send("assign_#{attribute}") }
        end

        def assign_device_role
          return if device.device_role&.id == device_role&.id

          device.device_role = device_role&.id
        end

        def assign_device_type
          return if device.device_type&.id == device_type&.id

          device.device_type = device_type&.id
        end

        def assign_primary_ip4
          return if device.primary_ip4&.id == primary_ip4

          device.primary_ip4 = primary_ip4
        end

        def assign_primary_ip6
          return if device.primary_ip6&.id == primary_ip6

          device.primary_ip6 = primary_ip6
        end

        def assign_site
          return if device.site&.id == site&.id

          device.site = site&.id
        end

        def assign_tenant
          return if device.tenant&.id == tenant&.id

          device.tenant = tenant&.id
        end

        def assign_serial
          new_serial = facts&.symbolize_keys&.fetch(:serialnumber, nil)
          return if !new_serial || device.serial == new_serial

          device.serial = new_serial
        end
      end
    end
  end
end
