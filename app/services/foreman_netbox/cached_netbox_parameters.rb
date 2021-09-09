# frozen_string_literal: true

module ForemanNetbox
  class CachedNetboxParameters
    def self.call(host)
      new(host).call
    end

    def initialize(host)
      @is_compute = host.compute?
      @data = host.netbox_facet.raw_data&.deep_symbolize_keys || {}
      @result = {}
    end

    def call
      additional_params = is_compute ? ForemanNetbox::NetboxFacet::VIRTUAL_MACHINE_PARAMS : ForemanNetbox::NetboxFacet::DEVICE_PARAMS
      (ForemanNetbox::NetboxFacet::COMMON_PARAMS + additional_params).map { |key| send("read_#{key}") }

      result
    end

    private

    attr_reader :data, :is_compute
    attr_accessor :result

    def read_interfaces
      return unless data.keys.include?(:interfaces)

      result[:interfaces] = data.fetch(:interfaces, {}).fetch(:results, []).map do |interface|
        interface.slice(:name, :mac_address)
                 .merge(type: interface.fetch(:type, {}).slice(:value))
                 .compact
      end
    end

    def read_ip_addresses
      return unless data.keys.include?(:ip_addresses)

      result[:ip_addresses] = data.fetch(:ip_addresses, {}).fetch(:results, []).map do |ip_address|
        ip_address.slice(:address)
                  .merge(interface: ip_address.fetch(:interface, {}).slice(:name))
      end
    end

    def read_virtual_machine
      return unless data.keys.include?(:virtual_machine)

      result[:virtual_machine] = data.fetch(:virtual_machine, {}).slice(:name, :vcpus, :memory, :disk)
    end

    def read_tenant
      return unless data.keys.include?(:tenant)

      result[:tenant] = data.fetch(:tenant, {}).slice(:name, :slug)
    end

    def read_cluster
      return unless data.keys.include?(:cluster)

      result[:cluster] = data.fetch(:cluster, {}).slice(:name)
    end

    def read_cluster_type
      return unless data.keys.include?(:cluster_type)

      result[:cluster_type] = data.fetch(:cluster_type, {}).slice(:name, :slug)
    end

    def read_device
      return unless data.keys.include?(:device)

      result[:device] = data.fetch(:device, {})
                            .slice(:name, :serial)
                            .compact
                            .reject { |k, v| k == :serial && v.blank? }
    end

    def read_device_role
      return unless data.keys.include?(:device_role)

      result[:device_role] = data.fetch(:device_role, {}).slice(:name, :color, :slug)
    end

    def read_device_type
      return unless data.keys.include?(:device_type)

      result[:device_type] = data.fetch(:device_type, {}).slice(:model, :slug)
    end

    def read_manufacturer
      return unless data.keys.include?(:manufacturer)

      result[:manufacturer] = data.fetch(:manufacturer, {}).slice(:name, :slug)
    end

    def read_site
      return unless data.keys.include?(:site)

      result[:site] = data.fetch(:site, {}).slice(:name, :slug)
    end
  end
end
