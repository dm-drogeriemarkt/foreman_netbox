# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        module SyncIpAddresses
          class Delete
            include ::Interactor

            def call
              if context.interfaces.reload.total.zero?
                context.ip_addresses.each(&:delete)
                return
              end

              context.interfaces.each do |netbox_interface|
                host_interface = host_interface_for(netbox_interface)
                host_interface_ips = ips_for(host_interface)

                context.ip_addresses
                       .select { |ip| ip['interface']['id'] == netbox_interface.id }
                       .reject { |ip| host_interface_ips.include?(ip['address']) }
                       .each(&:delete)
              end
            end

            private

            def host_interface_for(netbox_interface)
              context.host.interfaces.find { |i| i.name == netbox_interface.name }
            end

            def ips_for(host_interface)
              [host_interface&.ip, host_interface&.ip6].compact
            end
          end
        end
      end
    end
  end
end
