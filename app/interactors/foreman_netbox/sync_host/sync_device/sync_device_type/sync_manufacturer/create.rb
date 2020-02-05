# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Create
            include ::Interactor

            def call
              return if context.manufacturer

              context.manufacturer = ForemanNetbox::API.client::DCIM::Manufacturer.new(params).save
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            def params
              manufacturer_name = context.host.facts.symbolize_keys.fetch(:'dmi::manufacturer')

              {
                name: manufacturer_name,
                slug: manufacturer_name.parameterize
              }
            end
          end
        end
      end
    end
  end
end
