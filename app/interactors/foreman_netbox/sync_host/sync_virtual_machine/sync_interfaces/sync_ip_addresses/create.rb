# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        module SyncIpAddresses
          class Create
            include ::Interactor
            include ForemanNetbox::Concerns::AssignTags

            def call
              netbox_params.fetch(:ip_addresses, []).map do |ip_address|
                interface_id = interfaces_map.fetch(ip_address.dig(:interface, :name), nil)

                next unless interface_id
                next unless ForemanNetbox::API.client
                                              .ipam
                                              .ip_addresses
                                              .filter(vminterface_id: interface_id, address: ip_address[:address])
                                              .total
                                              .zero?

                ForemanNetbox::API.client::IPAM::IpAddress.new(
                  ip_address.slice(:address)
                            .merge(
                              assigned_object_type: 'virtualization.vminterface',
                              assigned_object_id: interface_id,
                              tags: default_tag_ids
                            )
                ).save
              end
            rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
              ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
              context.fail!(error: "#{self.class}: #{e}")
            end

            private

            delegate :interfaces, :netbox_params, to: :context

            def interfaces_map
              interfaces.each_with_object({}) do |int, memo|
                memo[int.name] = int.id
              end
            end
          end
        end
      end
    end
  end
end
