# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Create
          include ::Interactor

          around do |interactor|
            interactor.call unless context.site
          end

          def call
            context.site = ForemanNetbox::API.client::DCIM::Site.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          delegate :netbox_site_name, to: :'context.host.location'
          delegate :netbox_site_slug, to: :'context.host.location'

          def params
            {
              name: netbox_site_name,
              slug: netbox_site_slug
            }
          end
        end
      end
    end
  end
end
