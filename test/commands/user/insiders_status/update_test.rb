require 'test_helper'

class User::InsidersStatus::UpdateTest < ActiveSupport::TestCase
  %i[eligible_lifetime active_lifetime].each do |status|
    test "#{status} is a noop" do
      user = create :user, insiders_status: status
      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).never

      User::InsidersStatus::Update.(user)

      assert_equal status, user.reload.insiders_status
    end
  end

  %i[ineligible eligible].each do |status|
    test "#{status} -> ineligible" do
      user = create :user, insiders_status: status
      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:ineligible)

      User::InsidersStatus::Update.(user)

      assert_equal :ineligible, user.reload.insiders_status
    end
  end

  test "active -> ineligible" do
    user = create :user, insiders_status: :active
    User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:ineligible)

    User::SetDiscordRoles.expects(:defer).with(user)
    User::SetDiscourseGroups.expects(:defer).with(user)
    User::Notification::Create.expects(:defer).never
    User::UpdateFlair.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)

    assert_equal :ineligible, user.reload.insiders_status
  end

  %i[ineligible eligible eligible_lifetime].each do |status|
    test "unset -> #{status}: set discord roles" do
      user = create :user, insiders_status: :unset
      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(status)

      User::SetDiscordRoles.expects(:defer).with(user).never
      User::SetDiscourseGroups.expects(:defer).with(user).never
      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "active -> active_lifetime" do
    user = create :user, insiders_status: :active
    User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:active_lifetime)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge
    assert_equal :lifetime_insider, user.flair
  end

  test "active -> ineligible: user is premium until last payment date + 1 month + 15 days if that is in the future" do
    travel_to(Date.new(2025, 1, 1)) do
      user = create :user, insiders_status: :active, premium_until: Time.current
      subscription = create(:payments_subscription, :premium, status: :active, user:)
      create(:payments_payment, :premium, created_at: Time.current - 2.months, user:, subscription:)
      last_payment = create(:payments_payment, :premium, created_at: Time.current - 20.days, user:, subscription:)

      User::SetDiscourseGroups.stubs(:defer)

      perform_enqueued_jobs do
        User::InsidersStatus::Update.(user.reload)
      end

      assert_equal last_payment.created_at + 1.month + 15.days, user.reload.premium_until
      assert user.premium?
    end
  end

  test "ineligible: user is no longer premium when last payment date + 30 days is not in the future" do
    user = create :user, insiders_status: :active, premium_until: Time.current
    subscription = create(:payments_subscription, :premium, status: :active, user:)
    create(:payments_payment, :premium, created_at: Time.current - 2.months, subscription:)

    User::SetDiscourseGroups.stubs(:defer)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  test "ineligible: user is no longer premium when there are no payments" do
    user = create :user, insiders_status: :active, premium_until: Time.current

    User::SetDiscourseGroups.stubs(:defer)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_nil user.reload.premium_until
    refute user.premium?
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
      create :payments_payment, :donation, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

      User::InsidersStatus::Update.(user.reload)

      assert_equal expected_status, user.insiders_status
    end
  end

  %i[eligible eligible_lifetime active active_lifetime].each do |current_status|
    test "eligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      create :payments_payment, :donation, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible: notification created when current status is ineligible" do
    user = create :user, insiders_status: :ineligible

    # Make the user eligible
    create :payments_payment, :donation, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :eligible_for_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "eligible: set discord roles" do
    travel_to(Date.new(2025, 1, 1)) do
      user = create :user, insiders_status: :ineligible

      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible)

      User::InsidersStatus::Update.(user)
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

      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  %i[ineligible eligible].each do |current_status|
    test "eligible_lifetime: notification created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

      User::Notification::CreateEmailOnly.expects(:defer).with(user, :eligible_for_lifetime_insiders).once

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible_lifetime: notification created when current status is active" do
    user = create :user, insiders_status: :active

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    # TODO: Make this Create.(...)
    User::Notification::CreateEmailOnly.expects(:defer).with(user, :upgraded_to_lifetime_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "eligible_lifetime: lifetime insider badge awarded when current status is active" do
    user = create :user, insiders_status: :active

    User::SetDiscourseGroups.stubs(:defer)

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)
    refute_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge
  end
end
