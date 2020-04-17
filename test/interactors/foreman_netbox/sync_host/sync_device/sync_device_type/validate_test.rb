# frozen_string_literal: true

require 'test_plugin_helper'

class ValidateDeviceTypeTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::Validate.call(host: host) }

  context 'with valid attributes' do
    let(:host) do
      OpenStruct.new(
        facts: {
          'dmi::product::name': 'Device Type'
        }
      )
    end

    it 'does not raise an error' do
      assert_nothing_raised { subject }
    end
  end

  context 'with invalid attributes' do
    let(:host) do
      OpenStruct.new(
        facts: {}
      )
    end

    it 'raises an error' do
      assert_raises ForemanNetbox::SyncHost::ValidationOrganizer::HostAttributeError do
        subject
      end
    end
  end
end