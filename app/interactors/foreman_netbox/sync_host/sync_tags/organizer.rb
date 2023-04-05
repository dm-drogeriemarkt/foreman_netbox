# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncTags
      class Organizer
        include ::Interactor::Organizer

        DEFAULT_TAGS = [
          { name: 'foreman', slug: 'foreman' },
        ].freeze

        after do
          context.raw_data[:tags] = context.tags.map(&:raw_data!)
        end

        organize SyncTags::Find,
          SyncTags::Create
      end
    end
  end
end
