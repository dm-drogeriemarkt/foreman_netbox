# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      module SyncDeviceType
        module SyncManufacturer
          module Concerns
            module Manufacturer
              include ForemanNetbox::Concerns::Facts

              def manufacturer
                facts[:manufacturer] || facts[:'dmi::manufacturer']
              end
            end
          end
        end
      end
    end
  end
end
