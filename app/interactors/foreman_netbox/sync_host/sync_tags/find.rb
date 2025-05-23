# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTags
      class Find
        include ::Interactor

        def call
          context.tags = slugs.map do |slug|
            ForemanNetbox::Api.client.extras.tags.find_by(slug: slug)
          end.compact
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def slugs
          SyncTags::Organizer::DEFAULT_TAGS.pluck(:slug)
        end
      end
    end
  end
end
