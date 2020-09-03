# frozen_string_literal: true

module ForemanNetbox
  module Params
    class InterfaceParams < Dry::Schema::Params
      define do
        required(:name).filled(:string)
        required(:type).filled(:hash) do
          required(:value).filled(:string)
        end
        optional(:mac_address).maybe(:string)
        optional(:tags).array(:string)
      end
    end
  end
end
