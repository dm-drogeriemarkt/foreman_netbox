# frozen_string_literal: true

module ForemanNetbox
  module Params
    IpAddressParams = Dry::Schema.Params do
      required(:address).filled(:string)
      required(:interface).filled(:hash) do
        required(:name).filled(:string)
      end
      optional(:tags).array(:string)
    end
  end
end
