# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncInterfaces
        class Create
          include ::Interactor
          include ForemanNetbox::Concerns::AssignTags

          after do
            context.interfaces.reload
          end

          def call
            netbox_params.fetch(:interfaces, [])
                         .select { |i| i[:name] }
                         .reject { |i| interfaces.map(&:name).include?(i[:name]) }
                         .map do |new_interface|
                           ForemanNetbox::API.client::DCIM::Interface.new(
                             new_interface.except(:type)
                                          .merge(
                                            type: new_interface.dig(:type, :value),
                                            device: device.id,
                                            tags: default_tag_ids
                                          )
                           ).save
                         end
          rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
            ::Foreman::Logging.logger('foreman_netbox/import').error("#{self.class} error #{e}: #{e.backtrace}")
            context.fail!(error: "#{self.class}: #{e}")
          end

          delegate :device, :interfaces, :netbox_params, to: :context
        end
      end
    end
  end
end
