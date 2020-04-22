# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateSiteTest < ActiveSupport::TestCase
  let(:interactor) { ForemanNetbox::ValidateHost::ValidateDevice::ValidateSite::Validate }
  subject { interactor.call(host: host) }

  context 'with valid attributes' do
    let(:host) do
      OpenStruct.new(
        location: OpenStruct.new(
          name: 'Location'
        )
      )
    end

    it { assert subject.success? }
  end

  context 'with invalid attributes' do
    let(:host) do
      OpenStruct.new(
        location: OpenStruct.new
      )
    end

    it { assert_not subject.success? }
  end
end
