# frozen_string_literal: true

module ForemanNetbox
  module Params
    TenantParams = Dry::Schema.Params do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      optional(:tags).array(:string)
    end
  end
end
