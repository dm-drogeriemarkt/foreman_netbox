# frozen_string_literal: true

module ForemanNetbox
  module ValidateHost
    module ValidateDevice
      module ValidateSite
        class Validate
          include ::Interactor

          def call
            return if context.host.location&.name

            context.fail!(error: _('%s: Invalid manufacturer attributes') % self.class)
          end
        end
      end
    end
  end
end
