# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module Concerns
          module Productname
            include ForemanNetbox::Concerns::Facts

            UNKNOWN = 'Unknown'

            def productname
              facts[:productname] || facts[:'dmi::product::name'] || UNKNOWN
            end
          end
        end
      end
    end
  end
end
