# frozen_string_literal: true

module ForemanNetbox
  # rubocop:disable Metrics/ClassLength
  class NetboxParameters
    UNKNOWN = 'Unknown'
    DEFAULT_TAGS = ['foreman'].freeze
    DEFAULT_INTERFACE_TYPE = 'virtual'
    CLUSTER_TYPES = {
      :'Foreman::Model::Vmware' => {
        name: 'VMware ESXi',
        slug: 'vmware-esxi'
      }
    }.freeze
    DEVICE_ROLE = {
      name: 'SERVER',
      color: '9e9e9e',
      slug: 'server'
    }.freeze

    def self.call(host)
      new(host).call
    end

    def initialize(host)
      @host = host
    end

    def call
      additional_params = host.compute? ? ForemanNetbox::NetboxFacet::VIRTUAL_MACHINE_PARAMS : ForemanNetbox::NetboxFacet::DEVICE_PARAMS

      (ForemanNetbox::NetboxFacet::COMMON_PARAMS + additional_params).map do |param|
        send(param)
      end.reduce({}, :merge)
    end

    private

    attr_accessor :host
    delegate :netbox_facet, to: :host
    delegate :cached_netbox_params, to: :netbox_facet

    def tenant
      {
        tenant: {
          name: host.owner&.netbox_tenant_name,
          slug: host.owner&.netbox_tenant_slug,
          tags: DEFAULT_TAGS
        }
      }
    end

    def device
      {
        device: {
          name: host.name,
          serial: host.facts.deep_symbolize_keys[:serialnumber],
          tags: DEFAULT_TAGS
        }
      }
    end

    def device_role
      {
        device_role: DEVICE_ROLE
      }
    end

    def device_type
      model = host.facts.deep_symbolize_keys[:productname] || host.facts.deep_symbolize_keys[:'dmi::product::name'] || UNKNOWN

      {
        device_type: {
          model: model,
          slug: model.parameterize,
          tags: DEFAULT_TAGS
        }
      }
    end

    def manufacturer
      name = host.facts.deep_symbolize_keys[:manufacturer] || host.facts.deep_symbolize_keys[:'dmi::manufacturer'] || UNKNOWN

      {
        manufacturer: {
          name: name,
          slug: cached_netbox_params.dig(:manufacturer, :slug) || name.parameterize
        }
      }
    end

    def site
      {
        site: {
          name: host.location&.netbox_site_name,
          slug: host.location&.netbox_site_slug,
          tags: DEFAULT_TAGS
        }
      }
    end

    def interfaces
      {
        interfaces: host.interfaces.map do |interface|
          identifier = interface.identifier.present? && interface.identifier
          mac_address = interface.mac&.upcase

          {
            name: identifier || (mac_address && "Interface #{mac_address}"),
            mac_address: mac_address,
            type: {
              value: DEFAULT_INTERFACE_TYPE
            },
            tags: DEFAULT_TAGS
          }
        end
      }
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def ip_addresses
      {
        ip_addresses: host.interfaces.map do |interface|
          [
            interface.ip && interface.subnet && "#{interface.ip}/#{interface.subnet.cidr}",
            interface.ip6 && interface.subnet6 && "#{interface.ip6}/#{interface.subnet6.cidr}"
          ].compact.map do |ip_address|
            identifier = interface.identifier.present? && interface.identifier
            mac_address = interface.mac&.upcase

            {
              address: ip_address,
              interface: {
                name: identifier || (mac_address && "Interface #{mac_address}")
              },
              tags: DEFAULT_TAGS
            }
          end
        end.flatten
      }
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def virtual_machine
      {
        virtual_machine: {
          name: host.name,
          vcpus: host.compute_object&.cpus,
          memory: host.compute_object&.memory_mb,
          disk: host.compute_object&.volumes&.map(&:size_gb)&.reduce(&:+),
          tags: DEFAULT_TAGS
        }
      }
    end

    def cluster
      {
        cluster: {
          name: host.compute_object&.cluster,
          tags: DEFAULT_TAGS
        }
      }
    end

    def cluster_type
      type = host.compute_resource&.type&.to_sym

      {
        cluster_type: CLUSTER_TYPES.fetch(type, nil)
      }
    end
  end
  # rubocop:enable Metrics/ClassLength
end
