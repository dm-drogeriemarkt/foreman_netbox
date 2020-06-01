# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        module SyncIpAddresses
          class Update
            include ::Interactor

            def call
              default_tags = ForemanNetbox::SyncHost::Organizer::DEFAULT_TAGS
              context.ip_addresses.each do |ip_address|
                ip_address.tags = (ip_address.tags | default_tags) if (default_tags - ip_address.tags).any?

                ip_address.save
              end
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end
          end
        end
      end
    end
  end
end
