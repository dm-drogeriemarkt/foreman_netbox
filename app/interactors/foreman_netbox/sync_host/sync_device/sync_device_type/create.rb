# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        class Create
          include ::Interactor
          include SyncDeviceType::Concerns::Params

          around do |interactor|
            interactor.call unless context.device_type
          end

          def call
            context.device_type = ForemanNetbox::API.client::DCIM::DeviceType.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :manufacturer, to: :context

          def params
            {
              model: productname,
              slug: slug,
              manufacturer: manufacturer.id,
              tags: ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
            }
          end
        end
      end
    end
  end
end
