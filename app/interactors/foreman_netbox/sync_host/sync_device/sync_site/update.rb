# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Update
          include ::Interactor

          around do |interactor|
            interactor.call if context.site
          end

          def call
            new_tags = new_site_params.fetch(:tags, []) - site.tags
            site.tags = (site.tags | new_tags) if new_tags.any?

            site.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_params, :site, to: :context

          def new_site_params
            netbox_params.fetch(:site, {})
          end
        end
      end
    end
  end
end
