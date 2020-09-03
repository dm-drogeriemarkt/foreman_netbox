# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Find
          include ::Interactor

          def call
            context.interfaces = ForemanNetbox::API.client.virtualization.interfaces.filter(params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :virtual_machine, to: :context

          def params
            {
              virtual_machine_id: virtual_machine.id
            }
          end
        end
      end
    end
  end
end
