# frozen_string_literal: true

module Orchestration
  module Netbox
    extend ActiveSupport::Concern

    included do
      after_validation :queue_netbox_push
      before_destroy :queue_netbox_destroy
    end

    protected

    def queue_netbox_push
      return unless errors.empty?

      queue.create(name: _('Push host %s to Netbox') % self, priority: 100,
                   action: [self, :set_netbox])
    end

    def queue_netbox_destroy
      return unless errors.empty?

      queue.create(name: _('Delete host %s from Netbox') % self, priority: 60,
                   action: [self, :del_netbox])
    end

    def set_netbox
      logger.info "Pushing #{name} to Netbox"

      result = push_to_netbox
      return true if result.success?

      raise Foreman::Exception, result.error
    rescue StandardError => e
      Foreman::Logging.exception("Failed to push #{name} to Netbox.", e)
      failure format(_('Failed to push %{name} to Netbox: %{message}\n '), name: name, message: e.message), e
    end

    def del_netbox
      logger.info "Deleting #{name} from Netbox"

      result = delete_from_netbox
      return true if result.success?

      raise Foreman::Exception, result.error
    rescue StandardError => e
      Foreman::Logging.exception("Failed to delete #{name} from Netbox", e)
      failure format(_('Failed to delete %{name} from Netbox: %{message}\n '), name: name, message: e.message), e
    end
  end
end
