# frozen_string_literal: true

module ForemanNetbox
  module Params
    InterfaceParams = Dry::Schema.Params do
      required(:name).filled(:string)
      required(:type).filled(:hash) do
        required(:value).filled(:string)
      end
      optional(:mac_address).maybe(:string)
      optional(:tags).array(:string)
    end
  end
end
