# frozen_string_literal: true

module ForemanNetbox
  class Engine < ::Rails::Engine
    engine_name 'foreman_netbox'

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
  end
end
