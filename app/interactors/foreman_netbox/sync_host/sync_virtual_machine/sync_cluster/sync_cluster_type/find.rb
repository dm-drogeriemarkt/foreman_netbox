# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        module SyncClusterType
          class Find
            include ::Interactor

            def call
              return unless params

              context.cluster_type = ForemanNetbox::API.client.virtualization.cluster_types.find_by(params)
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            def params
              type = context.host.compute_resource&.type&.to_sym
              {
                slug: SyncClusterType::Organizer::CLUSTER_TYPES.dig(type, :slug)
              }
            end
          end
        end
      end
    end
  end
end
