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
            default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
            cluster.tags = (cluster.tags | default_tags) if (default_tags - cluster.tags).any?

            cluster.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :cluster, to: :context
        end
      end
    end
  end
end
