require 'test_helper'

class RecheckInsidersJobTest < ActiveJob::TestCase
  test "recheck active and eligible insiders" do
    active_user_1 = create :user, insiders_status: :active
    active_user_2 = create :user, insiders_status: :active
    eligible_user = create :user, insiders_status: :eligible
    create :user, insiders_status: :ineligible
    create :user, insiders_status: :eligible_lifetime
    create :user, insiders_status: :active_lifetime

    User::InsidersStatus::Update.expects(:call).with(active_user_1).once
    User::InsidersStatus::Update.expects(:call).with(active_user_2).once
    User::InsidersStatus::Update.expects(:call).with(eligible_user).once

    perform_enqueued_jobs do
      RecheckInsidersJob.perform_now
    end
  end
end
