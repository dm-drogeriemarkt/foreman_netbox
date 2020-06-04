# frozen_string_literal: true

module ForemanNetbox
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      include ::Orchestration::Netbox
    end

    def netbox_facet
      @netbox_facet ||= super || ForemanNetbox::NetboxFacet.new(host: self)
    end

    def push_to_netbox_async
      ForemanNetbox::SyncHostJob.perform_later(id)
    end

    def push_to_netbox
      ForemanNetbox::SyncHost::Organizer.call(host: self)
    end

    def delete_from_netbox
      ForemanNetbox::DeleteHost::Organizer.call(host: self)
    end
  end
end
