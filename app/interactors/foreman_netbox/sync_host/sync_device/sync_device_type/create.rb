# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Create
          include ::Interactor

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
              model: model,
              slug: model&.parameterize,
              manufacturer: context.manufacturer.id
            }
          end

          def model
            @model ||= context.host.facts.deep_symbolize_keys.dig(:dmi, :product, :name)
          end
        end
      end
    end
  end
end
