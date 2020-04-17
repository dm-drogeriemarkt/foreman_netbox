# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        module SyncClusterType
          class Create
            include ::Interactor

            def call
              return if context.cluster_type

              context.cluster_type = ForemanNetbox::API.client::Virtualization::ClusterType.new(params).save
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            def params
              type = context.host.compute_resource&.type&.to_sym
              SyncClusterType::Organizer::CLUSTER_TYPES.fetch(type)
            end
          end
        end
      end
    end
  end
end
