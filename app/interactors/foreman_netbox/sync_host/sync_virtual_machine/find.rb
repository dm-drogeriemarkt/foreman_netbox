# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Find
        include ::Interactor

        def call
          context.virtual_machine = find_by_mac || find_by_name
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :netbox_params, :host, to: :context
        delegate :mac, to: :host

        def find_by_mac
          ForemanNetbox::Api.client.virtualization.virtual_machines.filter(mac_address: mac).first if mac
        end

        def find_by_name
          params = netbox_params.fetch(:virtual_machine).slice(:name)
          ForemanNetbox::Api.client.virtualization.virtual_machines.find_by(params)
        end
      end
    end
  end
end
