require 'test_helper'

class User::InsidersStatus::TriggerUpdateTest < ActiveSupport::TestCase
  test "insiders_status set to unset if current status is ineligible" do
    user = create :user, insiders_status: :ineligible

    User::InsidersStatus::TriggerUpdate.(user)

    assert_equal :unset, user.insiders_status
  end

  %i[eligible eligible_lifetime active active_lifetime].each do |insiders_status|
    test "insiders_status not first unset if current status is #{insiders_status}" do
      user = create(:user, insiders_status:)

      User::InsidersStatus::TriggerUpdate.(user)

      assert_equal insiders_status, user.insiders_status
    end
  end

  test "updates insider_status" do
    user = create :user, insiders_status: :unset

    perform_enqueued_jobs do
      User::InsidersStatus::TriggerUpdate.(user)
    end

    assert_equal :ineligible, user.reload.insiders_status
  end

  %i[eligible_lifetime active_lifetime].each do |status|
    test "noop if #{status}" do
      user = create :user, insiders_status: status

      assert_no_enqueued_jobs do
        User::InsidersStatus::TriggerUpdate.(user)
      end

      assert_equal status, user.insiders_status
    end
  end
end
