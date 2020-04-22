# frozen_string_literal: true

module ForemanNetbox
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      include ::Orchestration::Netbox
    end

    def push_to_netbox
      ForemanNetbox::SyncHost::Organizer.call(host: self)
    end

    def delete_from_netbox
      ForemanNetbox::DeleteHost::Organizer.call(host: self)
    end
  end
end
