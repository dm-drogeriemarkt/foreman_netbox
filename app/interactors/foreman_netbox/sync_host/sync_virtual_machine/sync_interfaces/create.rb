# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncInterfaces
        class Create
          include ::Interactor

          after do
            context.interfaces.reload
          end

          def call
            netbox_params.fetch(:interfaces, [])
                         .select { |i| i[:name] }
                         .reject { |i| interfaces.map(&:name).include?(i[:name]) }
                         .map do |new_interface|
                           ForemanNetbox::API.client::Virtualization::Interface.new(
                             new_interface.except(:type).merge(virtual_machine: virtual_machine.id)
                           ).save
                         end
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :virtual_machine, :interfaces, :netbox_params, to: :context
        end
      end
    end
  end
end
