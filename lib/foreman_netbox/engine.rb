# frozen_string_literal: true

require 'dry-validation'
require 'netbox-client-ruby'
require 'interactor'

module ForemanNetbox
  class Engine < ::Rails::Engine
    engine_name 'foreman_netbox'

    config.autoload_paths += Dir["#{config.root}/app/interactors"]

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
        requires_foreman '>= 2.2'

        # Netbox Facet
        register_facet(ForemanNetbox::NetboxFacet, :netbox_facet) do
          set_dependent_action :destroy
        end

        # extend host show page
        extend_page('hosts/show') do |context|
          context.add_pagelet :main_tabs,
                              name: N_('Netbox'),
                              partial: 'hosts/netbox_tab',
                              onlyif: proc { |host| host.netbox_facet.synchronized_at }
        end

        logger :import, enabled: true
      end
    end

    config.to_prepare do
      ::Host::Managed.include(ForemanNetbox::HostExtensions)
      ::Location.include(ForemanNetbox::LocationExtensions)
      ::Nic::Base.include(ForemanNetbox::Nic::BaseExtensions)
      ::User.include(ForemanNetbox::UserUsergroupCommonExtensions)
      ::Usergroup.include(ForemanNetbox::UserUsergroupCommonExtensions)

      NetboxClientRuby.configure do |config|
        config.netbox.api_base_url = Setting::Netbox['netbox_url']
        config.netbox.auth.token = Setting::Netbox['netbox_api_token']
      end
    rescue StandardError => e
      Rails.logger.warn "ForemanNetbox: skipping engine hook (#{e})\n#{e.backtrace.join("\n")}"
    end
  end
end
