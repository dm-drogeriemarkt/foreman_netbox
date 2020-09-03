# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        module SyncIpAddresses
          class Update
            include ::Interactor

            def call
              context.ip_addresses.each do |ip_address|
                new_tags = tags_map.fetch(ip_address[:address], []) - ip_address.tags

                ip_address.tags = (ip_address.tags | new_tags) if new_tags.any?

                ip_address.save
              end
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            delegate :netbox_params, to: :context

            def tags_map
              netbox_params.fetch(:ip_addresses, [])
                           .each_with_object({}) do |item, memo|
                             memo[item[:address]] = item.fetch(:tags, [])
                           end
            end
          end
        end
      end
    end
  end
end
