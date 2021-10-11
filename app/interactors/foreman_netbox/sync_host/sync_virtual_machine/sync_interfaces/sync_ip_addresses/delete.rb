# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
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
                host_interface_ips = ip_addresses_netbox_params.select { |ip| ip.dig(:interface, :name) == netbox_interface.name }
                                                               .map { |ip| ip.fetch(:address) }

                context.ip_addresses
                       .select { |ip| ip['assigned_object_type'] == 'virtualization.vminterface' && ip['assigned_object_id'] == netbox_interface.id }
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
