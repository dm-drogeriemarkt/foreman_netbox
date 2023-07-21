# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Create
        include ::Interactor
        include ForemanNetbox::Concerns::AssignTags

        around do |interactor|
          interactor.call if !context.device && Setting[:netbox_create_devices]
        end

        def call
          context.device = ForemanNetbox::API.client::DCIM::Device.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :device_type, :device_role, :site, to: :context
        delegate :tenant, to: :context, allow_nil: true

        def params
          netbox_params.fetch(:device).merge(
            device_type: device_type.id,
            device_role: device_role.id,
            site: site.id,
            tenant: tenant&.id,
            tags: default_tag_ids
          ).compact
        end
      end
    end
  end
end
