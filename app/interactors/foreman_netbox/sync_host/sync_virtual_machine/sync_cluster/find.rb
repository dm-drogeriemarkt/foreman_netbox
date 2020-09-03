# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Find
          include ::Interactor

          def call
            context.cluster = ForemanNetbox::API.client.virtualization.clusters.find_by(params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, to: :context

          def params
            netbox_params.fetch(:cluster).slice(:name)
          end
        end
      end
    end
  end
end
