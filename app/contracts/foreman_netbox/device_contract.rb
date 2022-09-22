# frozen_string_literal: true

module ForemanNetbox
  class DeviceContract < Dry::Validation::Contract
    # rubocop:disable Metrics/BlockLength
    params do
      optional(:tenant).hash(ForemanNetbox::Params::TenantParams)
      optional(:ip_addresses).array(ForemanNetbox::Params::IpAddressParams)
      optional(:interfaces).array(ForemanNetbox::Params::InterfaceParams)

      required(:device).filled(:hash) do
        required(:name).filled(:string)
        optional(:serial).maybe(:string)
        optional(:tags).array(:string)
      end

      required(:device_type).filled(:hash) do
        required(:model).filled(:string)
        required(:slug).filled(:string)
        optional(:tags).array(:string)
      end

      required(:device_role).filled(:hash) do
        required(:name).filled(:string)
        required(:slug).filled(:string)
        optional(:color).maybe(:string)
      end

      required(:manufacturer).filled(:hash) do
        required(:name).filled(:string)
        required(:slug).filled(:string)
      end

      required(:site).filled(:hash) do
        required(:name).filled(:string)
        required(:slug).filled(:string)
        optional(:tags).array(:string)
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
