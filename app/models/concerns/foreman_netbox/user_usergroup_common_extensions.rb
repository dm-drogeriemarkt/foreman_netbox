# frozen_string_literal: true

module ForemanNetbox
  module UserUsergroupCommonExtensions
    NETBOX_TENANT_MAX_LENGTH = 100

    def netbox_tenant_name
      return name unless name.length > NETBOX_TENANT_MAX_LENGTH

      name_length = NETBOX_TENANT_MAX_LENGTH - id.to_s.length - 1
      "#{name.to_s.truncate(name_length, omission: '')}-#{id}"
    end

    def netbox_tenant_slug
      netbox_tenant_name&.parameterize
    end
  end
end
