# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Update
          include ::Interactor
          include ForemanNetbox::Concerns::AssignTags

          around do |interactor|
            interactor.call if context.device_type
          end

          def call
            assign_tags_to(device_type)

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
