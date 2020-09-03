# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanNetbox
  class NetboxParametersComparatorTest < ActiveSupport::TestCase
    subject { ForemanNetbox::NetboxParametersComparator.call(old_hash, new_hash) }

    context 'without differences' do
      let(:my_hash) do
        {
          device: {
            name: 'My device',
            tags: ['foreman']
          }
        }
      end
      let(:old_hash) { my_hash }
      let(:new_hash) { my_hash }
      let(:expected) { {} }

      it { assert_equal expected, subject }
    end

    context 'with differences' do
      let(:old_hash) do
        {
          device: {
            name: 'Old name',
            tags: ['custom']
          },
          device_role: {
            name: 'SERVER'
          },
          manufacturer: {
            name: 'Manufacturer',
            tags: %w[Synced foreman]
          },
          interfaces: [
            {
              name: 'eth0',
              type: {
                value: 'virtual'
              }
            },
            {
              name: 'eth1',
              type: {
                value: 'virtual'
              }
            },
            {
              name: 'eth2',
              type: {
                value: 'virtual'
              }
            },
            {
              name: 'eth4',
              mac_address: '00:50:56:84:6D:84',
              tags: ['foreman'],
              type: {
                value: 'virtual'
              }
            }
          ]
        }
      end

      let(:new_hash) do
        {
          device: {
            name: 'New name',
            tags: ['foreman']
          },
          device_type: {
            model: 'Model name'
          },
          manufacturer: {
            name: 'Manufacturer',
            tags: %w[foreman]
          },
          interfaces: [
            {
              name: 'eth0',
              type: {
                value: 'virtual'
              }
            },
            {
              name: 'eth1',
              type: {
                value: 'new_type'
              }
            },
            {
              name: 'eth3',
              type: {
                value: 'virtual'
              }
            },
            {
              name: 'eth4',
              mac_address: '00:50:56:84:6D:84',
              type: {
                value: 'virtual'
              },
              tags: ['foreman']
            }
          ]
        }
      end

      let(:expected) do
        {
          added: new_hash.slice(:device_type),
          removed: old_hash.slice(:device_role),
          device: {
            name: {
              old: old_hash.dig(:device, :name), new: new_hash.dig(:device, :name)
            },
            tags: {
              added: ['foreman'], removed: []
            }
          },
          interfaces: {
            added: new_hash[:interfaces].select { |i| %w[eth1 eth3].include?(i[:name]) },
            removed: old_hash[:interfaces].select { |i| %w[eth1 eth2].include?(i[:name]) }
          }
        }
      end

      it { assert_equal expected, subject }
    end
  end
end
