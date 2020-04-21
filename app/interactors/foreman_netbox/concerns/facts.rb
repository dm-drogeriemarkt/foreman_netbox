# frozen_string_literal: true

module ForemanNetbox
  module Concerns
    module Facts
      def facts
        context.host.facts.symbolize_keys
      end
    end
  end
end
