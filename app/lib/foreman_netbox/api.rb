# frozen_string_literal: true

module ForemanNetbox
  class API
    def self.client
      NetboxClientRuby.configure do |config|
        config.netbox.api_base_url = Setting::Netbox['netbox_url']
        config.netbox.auth.token = Setting::Netbox['netbox_api_token']
      end
    end
  end
end
