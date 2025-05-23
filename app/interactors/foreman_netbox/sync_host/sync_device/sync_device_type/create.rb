# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Create
          include ::Interactor
          include ForemanNetbox::Concerns::AssignTags

          around do |interactor|
            interactor.call unless context.device_type
          end

          def call
            context.device_type = ForemanNetbox::Api.client::DCIM::DeviceType.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, :manufacturer, to: :context

          def params
            netbox_params.fetch(:device_type)
                         .merge(manufacturer: manufacturer.id, tags: default_tag_ids)
                         .compact
          end
        end
      end
    end
  end
end
