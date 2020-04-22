# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          module Concerns
            module Params
              include ForemanNetbox::Concerns::Facts

              UNKNOWN = 'Unknown'

              def manufacturer
                facts[:manufacturer] || facts[:'dmi::manufacturer'] || UNKNOWN
              end

              def slug
                manufacturer.parameterize
              end
            end
          end
        end
      end
    end
  end
end
