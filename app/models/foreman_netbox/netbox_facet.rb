# frozen_string_literal: true

module ForemanNetbox
  class NetboxFacet < ApplicationRecord
    include Facets::Base

    COMMON_PARAMS = %i[interfaces ip_addresses tenant].freeze
    DEVICE_PARAMS = %i[device device_role device_type manufacturer site].freeze
    VIRTUAL_MACHINE_PARAMS = %i[virtual_machine cluster cluster_type].freeze

    validates :host, presence: true, allow_blank: false
    validates :url, uniqueness: true

    def synchronization_success?
      !synchronization_error
    end

    def netbox_params
      ForemanNetbox::NetboxParameters.call(host)
    end

    def cached_netbox_params
      ForemanNetbox::CachedNetboxParameters.call(host)
    end

    def netbox_params_diff
      ForemanNetbox::NetboxParametersComparator.call(cached_netbox_params, netbox_params)
    end

    def netbox_will_change?
      netbox_params_diff.keys.any?
    end
  end
end
