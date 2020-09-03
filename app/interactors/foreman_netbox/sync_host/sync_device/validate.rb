# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncDevice
      class Validate
        include ::Interactor

        def call
          validator = ForemanNetbox::DeviceContract.new.call(netbox_params)

          return if validator.success?

          message = validator.errors
                             .messages
                             .map { |m| "#{m.path} #{m.text}" }
                             .to_sentence
          context.fail!(error: _('Invalid Device parameters: %s') % message)
        end

        delegate :netbox_params, to: :context
      end
    end
  end
end
