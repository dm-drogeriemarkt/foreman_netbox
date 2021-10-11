# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Update
          include ::Interactor
          include ForemanNetbox::Concerns::AssignTags

          around do |interactor|
            interactor.call if context.cluster
          end

          def call
            assign_tags_to(cluster)

            cluster.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :cluster, to: :context
        end
      end
    end
  end
end
