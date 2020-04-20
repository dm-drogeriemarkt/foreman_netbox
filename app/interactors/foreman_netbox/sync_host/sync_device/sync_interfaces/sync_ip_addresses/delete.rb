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
                host_interface_ips = context.host.interfaces.find { |i| i.netbox_name == netbox_interface.name }&.netbox_ips

                context.ip_addresses
                       .select { |ip| ip['interface']['id'] == netbox_interface.id }
                       .reject { |ip| host_interface_ips.include?(ip['address']) }
                       .each(&:delete)
              end
            end
          end
        end
      end
    end
  end
end
