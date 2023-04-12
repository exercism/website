require 'test_helper'

class RecheckActiveInsidersJobTest < ActiveJob::TestCase
  test "recheck active insiders" do
    active_user_1 = create :user, insiders_status: :active
    active_user_2 = create :user, insiders_status: :active
    create :user, insiders_status: :ineligible
    create :user, insiders_status: :eligible
    create :user, insiders_status: :expired
    create :user, insiders_status: :active_lifetime

    User::InsidersStatus::Update.expects(:call).with(active_user_1).once
    User::InsidersStatus::Update.expects(:call).with(active_user_2).once

    perform_enqueued_jobs do
      RecheckActiveInsidersJob.perform_now
    end
  end
end
