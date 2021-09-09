# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class Create
          include ::Interactor
          include ForemanNetbox::Concerns::AssignTags

          around do |interactor|
            interactor.call unless context.cluster
          end

          def call
            context.cluster = ForemanNetbox::API.client::Virtualization::Cluster.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, to: :context
          delegate :cluster_type, to: :context, allow_nil: true

          def params
            netbox_params.fetch(:cluster).merge(
              type: cluster_type&.id,
              tags: default_tag_ids
            ).compact
          end
        end
      end
    end
  end
end
