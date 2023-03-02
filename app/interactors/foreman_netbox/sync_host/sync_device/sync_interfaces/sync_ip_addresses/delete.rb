# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        module SyncIpAddresses
          class Delete
            include ::Interactor

            before do
              context.interfaces.reload
            end

            def call
              if context.interfaces.total.zero?
                context.ip_addresses.each(&:delete)
                return
              end

              ip_addresses_netbox_params = netbox_params.fetch(:ip_addresses, [])

              context.interfaces.each do |netbox_interface|
                host_interface_ips = ip_addresses_netbox_params.select do |i|
                                       i.dig(:interface, :name) == netbox_interface.name
                                     end
                                                               .map { |i| i.fetch(:address) }

                context.ip_addresses
                       .select { |ip| ip['assigned_object_type'] == 'dcim.interface' && ip['assigned_object_id'] == netbox_interface.id }
                       .reject { |ip| host_interface_ips.include?(ip['address']) }
                       .each(&:delete)
              end
            end

            delegate :netbox_params, to: :context
          end
        end
      end
    end
  end
end
