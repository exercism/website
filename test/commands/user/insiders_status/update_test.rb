require 'test_helper'

class User::InsidersStatus::UpdateTest < ActiveSupport::TestCase
  [
    %i[ineligible ineligible],
    %i[eligible ineligible],
    %i[active ineligible],
    %i[eligible_lifetime eligible_lifetime],
    %i[active_lifetime active_lifetime]
  ].each do |(current_status, expected_status)|
    test "ineligible: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: :unset

      User::InsidersStatus::Update.(user, current_status)

      assert_equal expected_status, user.reload.insiders_status
    end
  end

  test "ineligible: notification created when current status is active" do
    user = create :user, insiders_status: :unset

    User::Notification::Create.expects(:call).with(user, :expired_insiders).once

    User::InsidersStatus::Update.(user, :active)
  end

  %i[ineligible eligible eligible_lifetime active_lifetime].each do |current_status|
    test "ineligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: :unset

      User::Notification::Create.expects(:call).never

      User::InsidersStatus::Update.(user, current_status)
    end
  end

  [
    %i[ineligible eligible],
    %i[eligible eligible],
    %i[active active],
    %i[eligible_lifetime eligible_lifetime],
    %i[active_lifetime active_lifetime]
  ].each do |(current_status, expected_status)|
    test "eligible: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: :unset

      # Make the user eligible
      user.update(active_donation_subscription: true)

      User::InsidersStatus::Update.(user, current_status)

      assert_equal expected_status, user.insiders_status
    end
  end

  [
    %i[ineligible eligible_lifetime],
    %i[eligible eligible_lifetime],
    %i[active active_lifetime],
    %i[eligible_lifetime eligible_lifetime],
    %i[active_lifetime active_lifetime]
  ].each do |(current_status, expected_status)|
    test "eligible_lifetime: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: :unset

      # Make the user eligible
      user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

      User::InsidersStatus::Update.(user, current_status)

      assert_equal expected_status, user.insiders_status
    end
  end
end
