# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Find
            include ::Interactor

            def call
              context.manufacturer = ForemanNetbox::API.client.dcim.manufacturers.find_by(params)
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            def params
              {
                slug: manufacturer.parameterize
              }
            end

            def manufacturer
              context.host.facts.deep_symbolize_keys.dig(:dmi, :manufacturer)
            end
          end
        end
      end
    end
  end
end
