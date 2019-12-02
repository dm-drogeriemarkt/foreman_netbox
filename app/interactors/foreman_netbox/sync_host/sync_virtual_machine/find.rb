# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Find
        include ::Interactor

        def call
          context.virtual_machine = ForemanNetbox::API.client.virtualization.virtual_machines.find_by(params)
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            name: context.host.name
          }
        end
      end
    end
  end
end
