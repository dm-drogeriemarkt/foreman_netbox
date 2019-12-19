# frozen_string_literal: true

module ForemanNetbox
  class SyncHostJob < ::ApplicationJob
    queue_as :netbox_queue

    def perform(host_id)
      Host::Managed.find(host_id)&.push_to_netbox
    end

    rescue_from(StandardError) do |error|
      Foreman::Logging.logger('background').error("Netbox: Error #{error}: #{error.backtrace}")
    end

    def humanized_name
      _('Push host to Netbox')
    end
  end
end
