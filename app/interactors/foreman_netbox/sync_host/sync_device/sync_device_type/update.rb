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
            default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
            device_type.tags = (device_type.tags | default_tags) if (default_tags - device_type.tags).any?

            device_type.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :device_type, to: :context
        end
      end
    end
  end
end
