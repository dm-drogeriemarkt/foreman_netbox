# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        module SyncIpAddresses
          class Create
            include ::Interactor

            def call
              context.interfaces.each do |netbox_interface|
                host_interface = host_interface_for(netbox_interface)

                ip_addresses_for(host_interface).each do |ip|
                  next unless ForemanNetbox::API.client.ipam.ip_addresses
                                                .filter(interface_id: netbox_interface.id, address: ip)
                                                .total.zero?

                  ForemanNetbox::API.client::IPAM::IpAddress.new(interface: netbox_interface.id, address: ip).save
                end
              end
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              Foreman::Logging.exception("#{self.class} error:", e)
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            def host_interface_for(netbox_interface)
              context.host.interfaces.find { |i| i.name == netbox_interface.name }
            end

            def ip_addresses_for(host_interface)
              [host_interface&.ip, host_interface&.ip6].compact
            end
          end
        end
      end
    end
  end
end
