# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Find
        include ::Interactor

        def call
          context.device = ForemanNetbox::API.client.dcim.devices.find_by(params)
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :name, to: :'context.host'

        def params
          {
            name: name
          }
        end
      end
    end
  end
end
