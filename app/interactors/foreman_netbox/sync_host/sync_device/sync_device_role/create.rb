# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        class Create
          include ::Interactor

          around do |interactor|
            interactor.call unless context.device_role
          end

          def call
            context.device_role = ForemanNetbox::API.client::DCIM::DeviceRole.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, to: :context

          def params
            netbox_params.fetch(:device_role).compact
          end
        end
      end
    end
  end
end
