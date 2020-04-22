# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceRole
        module Concerns
          module Params
            DEVICE_ROLE = {
              name: 'Server',
              color: '61affe'
            }.freeze

            def name
              DEVICE_ROLE[:name]
            end

            def slug
              name.parameterize
            end

            def color
              DEVICE_ROLE[:color]
            end
          end
        end
      end
    end
  end
end
