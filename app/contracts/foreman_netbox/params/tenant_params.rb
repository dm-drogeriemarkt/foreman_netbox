# frozen_string_literal: true

module ForemanNetbox
  module Params
    class TenantParams < Dry::Schema::Params
      define do
        required(:name).filled(:string)
        required(:slug).filled(:string)
        optional(:tags).array(:string)
      end
    end
  end
end
