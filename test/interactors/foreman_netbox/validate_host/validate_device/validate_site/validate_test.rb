# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateSiteTest < ActiveSupport::TestCase
  let(:interactor) { ForemanNetbox::ValidateHost::ValidateDevice::ValidateSite::Validate }
  subject { interactor.call(host: host) }

  context 'with location' do
    let(:host) do
      OpenStruct.new(
        location: FactoryBot.build_stubbed(:location)
      )
    end

    it { assert subject.success? }
  end

  context 'without location' do
    let(:host) { OpenStruct.new }

    it { assert_not subject.success? }
  end
end
