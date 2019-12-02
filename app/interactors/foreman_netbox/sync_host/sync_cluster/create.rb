# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncCluster
      class Create
        include ::Interactor

        def call
          return if context.cluster

          context.cluster = ForemanNetbox::API.client::Virtualization::Cluster.new(params).save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            type: context.cluster_type&.id,
            name: context.host.compute_object&.cluster
          }
        end
      end
    end
  end
end
