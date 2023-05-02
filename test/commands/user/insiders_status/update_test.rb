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
      user = create :user, insiders_status: current_status

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.reload.insiders_status
    end
  end

  test "ineligible: notification created when current status is active" do
    user = create :user, insiders_status: :active

    User::Notification::Create.expects(:call).with(user, :expired_insiders).once

    User::InsidersStatus::Update.(user)
  end

  %i[ineligible eligible eligible_lifetime active_lifetime].each do |current_status|
    test "ineligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::Notification::Create.expects(:call).never

      User::InsidersStatus::Update.(user)
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
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(active_donation_subscription: true)

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  %i[eligible eligible_lifetime active active_lifetime].each do |current_status|
    test "eligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(active_donation_subscription: true)

      User::Notification::Create.expects(:call).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible: notification created when current status is ineligible" do
    user = create :user, insiders_status: :ineligible

    # Make the user eligible
    user.update(active_donation_subscription: true)

    User::Notification::Create.expects(:call).with(user, :join_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "eligible: insider badge awarded when current status is active_lifetime" do
    user = create :user, insiders_status: :active_lifetime

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    # Make the user eligible
    user.update(active_donation_subscription: true)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  test "eligible: insider badge awarded when current status is active" do
    user = create :user, insiders_status: :active

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    # Make the user eligible
    user.update(active_donation_subscription: true)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  [
    %i[ineligible eligible_lifetime],
    %i[eligible eligible_lifetime],
    %i[active active_lifetime],
    %i[eligible_lifetime eligible_lifetime],
    %i[active_lifetime active_lifetime]
  ].each do |(current_status, expected_status)|
    test "eligible_lifetime: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  %i[eligible_lifetime active_lifetime].each do |current_status|
    test "eligible_lifetime: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

      User::Notification::Create.expects(:call).never

      User::InsidersStatus::Update.(user)
    end
  end

  %i[ineligible eligible].each do |current_status|
    test "eligible_lifetime: notification created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

      User::Notification::Create.expects(:call).with(user, :join_lifetime_insiders).once

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible_lifetime: notification created when current status is active" do
    user = create :user, insiders_status: :active

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    User::Notification::Create.expects(:call).with(user, :joined_lifetime_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "eligible_lifetime: insider badge awarded when current status is active_lifetime" do
    user = create :user, insiders_status: :active_lifetime

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  test "eligible_lifetime: insider badge awarded when current status is active" do
    user = create :user, insiders_status: :active

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  test "eligible_lifetime: awards insiders badge when current status is active" do
    user = create :user, insiders_status: :active

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end
end
