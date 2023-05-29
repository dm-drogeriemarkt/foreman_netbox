# frozen_string_literal: true

module ForemanNetbox
  class API
    def self.client
      NetboxClientRuby.configure do |config|
        config.netbox.api_base_url = netbox_api_url
        config.netbox.auth.token = Setting['netbox_api_token']
      end
    end

    def self.netbox_api_url
      return Setting['netbox_api_url'] if URI.parse(Setting['netbox_api_url']).is_a?(URI::HTTP)

      api_url = "#{Setting['netbox_url']}/api"
      return api_url if URI.parse(api_url).is_a?(URI::HTTP)

      raise Foreman::Exception, 'Invalid Netbox API URL, please check the netbox_url and netbox_api_url settings'
    end
  end
end
