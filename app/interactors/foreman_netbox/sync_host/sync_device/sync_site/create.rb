# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Create
          include ::Interactor

          def call
            return if context.site

            context.site = ForemanNetbox::API.client::DCIM::Site.new(params).save
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            site_name = context.host.location.name

            {
              name: site_name,
              slug: site_name.parameterize
            }
          end
        end
      end
    end
  end
end
