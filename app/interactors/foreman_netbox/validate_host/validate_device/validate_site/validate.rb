# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      module ValidateSite
        class Validate
          include ::Interactor

          def call
            return true if netbox_site_name && netbox_site_slug

            context.fail!(error: _('%s: Invalid site attributes') % self.class)
          end

          delegate :netbox_site_name, to: :'context.host.location', allow_nil: true
          delegate :netbox_site_slug, to: :'context.host.location', allow_nil: true
        end
      end
    end
  end
end
