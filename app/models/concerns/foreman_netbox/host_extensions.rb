# frozen_string_literal: true

module ForemanNetbox
  module HostExtensions
    def push_to_netbox
      ForemanNetbox::SyncHost::Organizer.call(host: self).success?
    end

    def push_to_netbox!
      result = ForemanNetbox::SyncHost::Organizer.call(host: self)
      result.success? || raise(PushToNetboxError, result.error)
    end

    class PushToNetboxError < StandardError; end
  end
end
