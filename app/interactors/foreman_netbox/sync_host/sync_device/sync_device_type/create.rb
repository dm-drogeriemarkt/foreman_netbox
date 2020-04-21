# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Create
          include ::Interactor
          include SyncDeviceType::Concerns::Productname

          def call
            return if context.device_type

            context.device_type = ForemanNetbox::API.client::DCIM::DeviceType.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            {
              model: productname,
              slug: productname&.parameterize,
              manufacturer: context.manufacturer.id
            }
          end
        end
      end
    end
  end
end
