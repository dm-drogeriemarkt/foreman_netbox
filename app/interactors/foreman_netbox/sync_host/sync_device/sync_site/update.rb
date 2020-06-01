# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Update
          include ::Interactor

          ATTRIBUTES = %i[tags].freeze

          around do |interactor|
            interactor.call if context.site
          end

          def call
            default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
            site.tags = (site.tags | default_tags) if (default_tags - site.tags).any?

            site.save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :site, to: :context
        end
      end
    end
  end
end
