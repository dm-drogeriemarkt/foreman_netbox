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
        set('netbox_orchestration_enabled', N_('Enable Netbox Orchestration'), false, N_('Netbox Orchestration')),
        set('netbox_skip_site_update', N_('Skip updating Site attribute for Devices'), false, N_('Skip Site Update'))
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings
          .map { |s| s.merge(category: 'Setting::Netbox') }
          .map { |s| s.slice(*column_names.map(&:to_sym)) }
          .map { |s| find_or_initialize_by(s.slice(:name)).update!(s) }
      end

      true
    end

    def self.humanized_category
      N_('Netbox')
    end
  end
end
