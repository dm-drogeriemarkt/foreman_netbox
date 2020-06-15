# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      class Find
        include ::Interactor

        def call
          # rubocop:disable Rails/DynamicFindBy
          context.virtual_machine = find_by_mac || find_by_name
          # rubocop:enable Rails/DynamicFindBy
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        delegate :host, to: :context
        delegate :name, :mac, to: :host

        def find_by_mac
          ForemanNetbox::API.client.virtualization.virtual_machines.filter(mac_address: mac).first if mac
        end

        def find_by_name
          ForemanNetbox::API.client.virtualization.virtual_machines.find_by(name: name)
        end
      end
    end
  end
end
