# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateManufacturerTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::SyncManufacturer::Validate.call(host: host) }

  context 'with facts' do
    let(:host) do
      OpenStruct.new(
        facts: {
          'dmi::manufacturer': 'Manufacturer'
        }
      )
    end

    it 'does not raise an error' do
      assert_nothing_raised { subject }
    end
  end

  context 'without facts' do
    let(:host) do
      OpenStruct.new(
        facts: {}
      )
    end

    it 'does not raise an error' do
      assert_nothing_raised { subject }
    end
  end
end
