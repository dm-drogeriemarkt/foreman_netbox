# frozen_string_literal: true

require 'netbox-client-ruby'

module ForemanNetbox
  class Engine < ::Rails::Engine
    engine_name 'foreman_netbox'

    initializer 'foreman_netbox.load_default_settings', before: :load_config_initializers do
      require_dependency File.expand_path('../../app/models/setting/netbox.rb', __dir__) if begin
                                                                                              Setting.table_exists?
                                                                                            rescue StandardError
                                                                                              (false)
                                                                                            end
    end

    # Add any db migrations
    initializer 'foreman_netbox.load_app_instance_data' do |app|
      ForemanNetbox::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_netbox.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_netbox do
        requires_foreman '>= 1.24'
      end
    end

    config.to_prepare do
      begin
        NetboxClientRuby.configure do |config|
          config.netbox.api_base_url = Setting::Netbox['netbox_url']
          config.netbox.auth.token = Setting::Netbox['netbox_api_token']
        end
      rescue StandardError => e
        Rails.logger.warn "ForemanNetbox: skipping engine hook (#{e})\n#{e.backtrace.join("\n")}"
      end
    end
  end
end
