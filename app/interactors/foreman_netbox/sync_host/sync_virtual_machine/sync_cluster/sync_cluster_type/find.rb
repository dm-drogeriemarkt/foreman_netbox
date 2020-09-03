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
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            delegate :netbox_params, to: :context

            def params
              netbox_params.fetch(:cluster_type).slice(:slug)
            end
          end
        end
      end
    end
  end
end
