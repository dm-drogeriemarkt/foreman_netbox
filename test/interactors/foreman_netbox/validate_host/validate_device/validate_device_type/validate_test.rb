# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateDeviceTypeTest < ActiveSupport::TestCase
  let(:interactor) { ForemanNetbox::ValidateHost::ValidateDevice::ValidateDeviceType::Validate }
  subject { interactor.call(host: host) }

  context 'with facts' do
    let(:host) do
      OpenStruct.new(
        facts: {
          'dmi::product::name': 'Device Type'
        }
      )
    end

    it { assert subject.success? }
  end

  context 'without facts' do
    let(:host) do
      OpenStruct.new(
        facts: {}
      )
    end

    it { assert subject.success? }
  end
end
