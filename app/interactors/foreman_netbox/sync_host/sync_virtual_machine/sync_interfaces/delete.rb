# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Delete
          include ::Interactor

          around do |interactor|
            interactor.call unless context.interfaces.total.zero?
          end

          def call
            context.interfaces
                   .reject { |netbox_interface| interfaces_names.include?(netbox_interface.name) }
                   .each(&:delete)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, to: :context

          def interfaces_names
            netbox_params.fetch(:interfaces, [])
                         .map { |i| i[:name] }
                         .compact
          end
        end
      end
    end
  end
end
