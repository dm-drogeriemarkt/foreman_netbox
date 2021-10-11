# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        module SyncIpAddresses
          class Update
            include ::Interactor
            include ForemanNetbox::Concerns::AssignTags

            def call
              context.ip_addresses.each do |ip_address|
                assign_tags_to(ip_address)

                ip_address.save
              end
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end
          end
        end
      end
    end
  end
end
