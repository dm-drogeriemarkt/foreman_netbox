# frozen_string_literal: true

module ForemanNetbox
  module LocationExtensions
    def netbox_site_name
      parameters.fetch('netbox_site', name)
    end

    def netbox_site_slug
      netbox_site_name&.parameterize
    end
  end
end
