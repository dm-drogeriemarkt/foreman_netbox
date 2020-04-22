# frozen_string_literal: true

module ForemanNetbox
  module DeleteHost
    class DeleteDevice
      include ::Interactor

      def call
        return if context.host.compute?

        ForemanNetbox::API.client.dcim.devices.find_by(name: context.host.name)&.delete
      rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
        Foreman::Logging.exception("#{self.class} error:", e)
        context.fail!(error: "#{self.class}: #{e}")
      end
    end
  end
end
