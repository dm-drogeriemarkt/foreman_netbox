# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Update
          include ::Interactor

          around do |interactor|
            interactor.call if context.device_type
          end

          def call
            new_tags = new_device_type_params.fetch(:tags, []) - device_type.tags
            device_type.tags = (device_type.tags | new_tags) if new_tags.any?

            device_type.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :netbox_params, :device_type, to: :context

          def new_device_type_params
            netbox_params.fetch(:device_type, {})
          end
        end
      end
    end
  end
end
