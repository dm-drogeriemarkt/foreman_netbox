# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        module SyncClusterType
          class Create
            include ::Interactor

            around do |interactor|
              interactor.call unless context.cluster_type
            end

            def call
              context.cluster_type = ForemanNetbox::API.client::Virtualization::ClusterType.new(params).save
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            delegate :netbox_params, to: :context

            def params
              netbox_params.fetch(:cluster_type).compact
            end
          end
        end
      end
    end
  end
end
