# frozen_string_literal: true

require 'test_plugin_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.build(:host, :managed) }

    context 'a host with Netbox orchestration' do
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

      test '#set_netbox is called during orchestration' do
        host.stubs(:skip_orchestration_for_testing?).returns(false) # Explicitly enable orchestration
        host.expects(:set_netbox).returns(true)
        assert host.save
      end

      test '#set_netbox' do
        host.expects(:push_to_netbox_async)
        host.send(:set_netbox)
      end

      test '#del_netbox' do
        host.expects(:delete_from_netbox)
        host.send(:del_netbox)
      end
    end

    test '#push_to_netbox_async' do
      ForemanNetbox::SyncHostJob.expects(:perform_later).with(host.id)
      host.push_to_netbox_async
    end

    test '#push_to_netbox' do
      ::ForemanNetbox::SyncHost::Organizer.expects(:call).with(host: host)
      host.push_to_netbox
    end

    test '#delete_from_netbox' do
      ::ForemanNetbox::DeleteHost::Organizer.expects(:call).with(host: host)
      host.delete_from_netbox
    end
  end
end
