# frozen_string_literal: true

class Setting
  class Netbox < ::Setting
    BLANK_ATTRS << 'netbox_url'
    BLANK_ATTRS << 'netbox_api_token'
    URI_BLANK_ATTRS << 'netbox_url'

    def self.default_settings
      [
        set('netbox_url', N_('URL where Netbox is reachable'), nil, N_('Netbox URL')),
        set('netbox_api_token', N_('API token to Netbox'), nil, N_('Netbox API token'), nil, encrypted: true),
        set('netbox_orchestration_enabled', N_('Enable Netbox Orchestration'), false, N_('Netbox Orchestration'))
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each { |s| create! s.update(category: 'Setting::Netbox') }
      end

      true
    end

    def self.humanized_category
      N_('Netbox')
    end
  end
end
