# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class APITest < ActiveSupport::TestCase
    describe '.netbox_api_url' do
      subject { described_class.netbox_api_url }

      let(:netbox1_url) { 'https://netbox1.com' }
      let(:netbox1_api_url) { "#{netbox1_url}/api" }
      let(:netbox2_api_url) { 'https://netbox1.com/api' }

      context 'when only the netbox_url setting is set' do
        setup do
          Setting[:netbox_url] = netbox1_url
        end

        it 'returns the URL to the Netbox API' do
          assert_equal netbox1_api_url, subject
        end
      end

      context 'when only the netbox_api_url setting is set' do
        setup do
          Setting[:netbox_api_url] = netbox2_api_url
        end

        it 'returns the URL to the Netbox API' do
          assert_equal netbox2_api_url, subject
        end
      end

      context 'when both netbox_url and netbox_api_url setting are set' do
        setup do
          Setting[:netbox_url] = netbox1_api_url
          Setting[:netbox_api_url] = netbox2_api_url
        end

        it 'returns the URL to the Netbox API from netbox_api_url setting' do
          assert_equal netbox2_api_url, subject
        end
      end

      context 'when neither setting netbox_url nor netbox_api_url is set' do
        it 'raises exception' do
          assert_raises(Foreman::Exception) { subject }
        end
      end
    end
  end
end
