# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          class Find
            include ::Interactor

            def call
              context.manufacturer = find_by_slug || find_by_name
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError,
                   NetboxClientRuby::RemoteError => e
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            delegate :netbox_params, to: :context

            def find_by_slug
              params = netbox_params.fetch(:manufacturer).slice(:slug)

              ForemanNetbox::API.client.dcim.manufacturers.find_by(params)
            end

            def find_by_name
              params = netbox_params.fetch(:manufacturer).slice(:name)

              ForemanNetbox::API.client.dcim.manufacturers.find_by(params)
            end
          end
        end
      end
    end
  end
end
