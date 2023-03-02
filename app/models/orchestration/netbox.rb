# frozen_string_literal: true

module Orchestration
  module Netbox
    extend ActiveSupport::Concern

    included do
      after_validation :queue_netbox_push, if: :netbox_orchestration_allowed?
      before_destroy :queue_netbox_destroy
    end

    delegate :netbox_will_change?, :netbox_params_diff, to: :netbox_facet

    protected

    def netbox_orchestration_allowed?
      Setting[:netbox_orchestration_enabled] && netbox_will_change?
    end

    def queue_netbox_push
      return unless errors.empty? && managed?

      ::Foreman::Logging.logger('foreman_netbox/import')
                        .info("Queued import of #{name} to Netbox. Changes that will be sent: #{netbox_params_diff}")

      post_queue.create(name: _('Push host %s to Netbox') % self, priority: 100, action: [self, :set_netbox])
    end

    def queue_netbox_destroy
      return unless errors.empty? && managed?

      ::Foreman::Logging.logger('foreman_netbox/import')
                        .info("Queued delete of #{name} from Netbox.")

      queue.create(name: _('Delete host %s from Netbox') % self, priority: 60, action: [self, :del_netbox])
    end

    def set_netbox
      ::Foreman::Logging.logger('foreman_netbox/import')
                        .info("Pushing #{name} to Netbox")

      push_to_netbox_async
    rescue StandardError => e
      ::Foreman::Logging.logger('foreman_netbox/import')
                        .error("Failed to push #{name} to Netbox. Error #{e}: #{e.backtrace}")

      failure format(_('Failed to push %{name} to Netbox: %{message}\n '), name: name, message: e.message), e
    end

    def del_netbox
      ::Foreman::Logging.logger('foreman_netbox/import')
                        .info("Deleting #{name} from Netbox")

      result = delete_from_netbox
      return true if result.success?

      raise Foreman::Exception, result.error
    rescue StandardError => e
      ::Foreman::Logging.logger('foreman_netbox/import')
                        .error("Failed to delete #{name} from Netbox. Error #{e}: #{e.backtrace}")

      failure format(_('Failed to delete %{name} from Netbox: %{message}\n '), name: name, message: e.message), e
    end
  end
end
