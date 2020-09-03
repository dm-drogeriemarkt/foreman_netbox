# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Update
          include ::Interactor

          around do |interactor|
            interactor.call if context.cluster
          end

          def call
            new_tags = new_cluster_params.fetch(:tags, []) - cluster.tags
            cluster.tags = (cluster.tags | new_tags) if new_tags.any?

            cluster.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, :cluster, to: :context

          def new_cluster_params
            netbox_params.fetch(:cluster, {})
          end
        end
      end
    end
  end
end
