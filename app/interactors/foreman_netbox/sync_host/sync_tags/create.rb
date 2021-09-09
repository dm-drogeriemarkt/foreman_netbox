# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTags
      class Create
        include ::Interactor

        def call
          context.tags.push(*new_tags)
        end

        private

        def new_tags
          SyncTags::Organizer::DEFAULT_TAGS
            .reject { |params| existing_slugs.include?(params[:slug]) }
            .map { |params| ForemanNetbox::API.client::Extras::Tag.new(params).save }
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        def existing_slugs
          @existing_slugs ||= context.tags.pluck(:slug)
        end
      end
    end
  end
end
