# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncSite
        class Find
          include ::Interactor

          def call
            context.site = ForemanNetbox::API.client.dcim.sites.find_by(params)
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            Foreman::Logging.exception("#{self.class} error:", e)
            context.fail!(error: "#{self.class}: #{e}")
          end

          private

          def params
            {
              slug: context.host.location.name.parameterize
            }
          end
        end
      end
    end
  end
end
