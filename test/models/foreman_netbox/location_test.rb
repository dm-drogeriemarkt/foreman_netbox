# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class LocationTest < ActiveSupport::TestCase
    describe '#netbox_site_name' do
      context 'with netbox_site parameter' do
        let(:loc) do
          FactoryBot.create(:location).tap do |location|
            location.location_parameters.create!(name: 'netbox_site', value: 'My Site')
          end
        end

        it { assert_equal loc.parameters['netbox_site'], loc.netbox_site_name }
      end

      context 'without netbox_site parameter' do
        let(:loc) { FactoryBot.create(:location) }

        it { assert_equal loc.name, loc.netbox_site_name }
      end
    end

    describe '#netbox_site_slug' do
      context 'with netbox_site parameter' do
        let(:loc) do
          FactoryBot.create(:location).tap do |location|
            location.location_parameters.create!(name: 'netbox_site', value: 'My Site')
          end
        end

        it { assert_equal loc.parameters['netbox_site'].parameterize, loc.netbox_site_slug }
      end
      context 'without netbox_site parameter' do
        let(:loc) { FactoryBot.create(:location) }

        it { assert_equal loc.name.parameterize, loc.netbox_site_slug }
      end
    end
  end
end
