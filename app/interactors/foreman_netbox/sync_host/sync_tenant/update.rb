# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTenant
      class Update
        include ::Interactor

        ATTRIBUTES = %i[tags].freeze

        around do |interactor|
          interactor.call if context.tenant
        end

        def call
          default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
          tenant.tags = (tenant.tags | default_tags) if (default_tags - tenant.tags).any?

          tenant.save
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        delegate :tenant, to: :context
      end
    end
  end
end
