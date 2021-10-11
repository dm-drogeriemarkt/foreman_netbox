# frozen_string_literal: true

module ForemanNetbox
  module Concerns
    module AssignTags
      delegate :tags, to: :context

      def assign_tags_to(object)
        current_tag_ids = object.tags.pluck('id')

        return if (default_tag_ids - current_tag_ids).empty?

        object.tags = current_tag_ids | default_tag_ids
      end

      def default_tag_ids
        tags.map(&:id)
      end
    end
  end
end
