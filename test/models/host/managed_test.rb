# frozen_string_literal: true

require 'test_plugin_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    context 'a host with Netbox orchestration' do
      let(:host) { FactoryBot.build(:host, :managed) }

      setup do
        disable_orchestration
        setup_default_netbox_settings
      end

      test 'should queue Netbox sync' do
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Push host #{host} to Netbox"
        assert_equal 1, tasks.size
      end

      test 'should queue Netbox destroy' do
        assert_valid host
        host.queue.clear
        host.destroy
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Delete host #{host} from Netbox"
        assert_equal 1, tasks.size
      end

      test '#push_netbox is called during orchestration' do
        host.stubs(:skip_orchestration_for_testing?).returns(false) # Explicitly enable orchestration
        host.expects(:push_netbox).returns(true)
        assert host.save
      end

      test '#push_netbox' do
        ::ForemanNetbox::SyncHost::Organizer.any_instance.expects(:call)
        host.send(:push_netbox)
      end

      test '#delete_netbox' do
        ::ForemanNetbox::DeleteHost::Organizer.any_instance.expects(:call)
        host.send(:delete_netbox)
      end
    end
  end
end
