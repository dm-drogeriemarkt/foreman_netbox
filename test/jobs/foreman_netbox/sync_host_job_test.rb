# frozen_string_literal: true

require 'test_plugin_helper'

class SyncHostJobTest < ActiveJob::TestCase
  let(:host) { FactoryBot.create(:host) }

  test 'push host to the Netbox' do
    Host::Managed.expects(:find).with(host.id).returns(host)
    host.expects(:push_to_netbox)

    ForemanNetbox::SyncHostJob.perform_now(host.id)
  end
end
