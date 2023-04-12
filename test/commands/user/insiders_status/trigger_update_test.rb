require 'test_helper'

class User::InsidersStatus::TriggerUpdateTest < ActiveSupport::TestCase
  test "insiders_status set to unset" do
    user = create :user, insiders_status: :ineligible

    User::InsidersStatus::TriggerUpdate.(user)

    assert_equal :unset, user.insiders_status
  end

  test "updates insider_status" do
    user = create :user, insiders_status: :active

    perform_enqueued_jobs do
      User::InsidersStatus::TriggerUpdate.(user)
    end

    assert_equal :ineligible, user.reload.insiders_status
  end
end
