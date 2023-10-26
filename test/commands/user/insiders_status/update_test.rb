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

  %w[dark system].each do |theme|
    test "active -> ineligible: reset insider-only #{theme} theme to light theme" do
      user = create :user, insiders_status: :active
      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:ineligible)

      User::SetDiscordRoles.expects(:defer).with(user)
      User::SetDiscourseGroups.expects(:defer).with(user)
      User::Notification::Create.expects(:defer).never
      User::UpdateFlair.expects(:defer).with(user)

      user.preferences.update(theme:)

      User::InsidersStatus::Update.(user)

      assert_equal "light", user.preferences.reload.theme
    end
  end

  %w[accessibility-dark sepia light].each do |theme|
    test "active -> ineligible: don't reset #{theme}" do
      user = create :user, insiders_status: :active
      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:ineligible)

      User::SetDiscordRoles.expects(:defer).with(user)
      User::SetDiscourseGroups.expects(:defer).with(user)
      User::Notification::Create.expects(:defer).never
      User::UpdateFlair.expects(:defer).with(user)

      user.preferences.update(theme:)

      User::InsidersStatus::Update.(user)

      assert_equal theme, user.preferences.reload.theme
    end
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
    User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible_lifetime)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge
    assert_equal :lifetime_insider, user.flair
  end

  test "active -> ineligible: user is insider until last payment date + 1 month + 15 days if that is in the future" do
    user = create :user, insiders_status: :active
    create(:payments_payment, created_at: Time.current - 2.months, user:)
    last_payment = create(:payments_payment, created_at: Time.current - 20.days, user:,
      amount_in_cents: Insiders::MINIMUM_AMOUNT_IN_CENTS)

    User::SetDiscourseGroups.stubs(:defer)

    perform_enqueued_jobs { User::InsidersStatus::Update.(user.reload) }
    assert user.insider?

    # Before 15 days
    travel_to(last_payment.created_at + 1.month + 14.days) do
      perform_enqueued_jobs { User::InsidersStatus::Update.(user.reload) }
      assert user.insider?
    end

    # After 15 days
    travel_to(last_payment.created_at + 1.month + 16.days) do
      perform_enqueued_jobs { User::InsidersStatus::Update.(user.reload) }
      refute user.insider?
    end
  end

  test "ineligible: user is no longer insider when there are no payments" do
    user = create :user, insiders_status: :active

    User::SetDiscourseGroups.stubs(:defer)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    refute user.insider?
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

      travel_to Time.utc(2023, 6, 29) do
        # Make the user eligible
        create :payments_payment, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

        User::InsidersStatus::Update.(user.reload)

        assert_equal expected_status, user.insiders_status
      end
    end
  end

  %i[eligible eligible_lifetime active active_lifetime].each do |current_status|
    test "eligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      create :payments_payment, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible: notification created when current status is ineligible" do
    travel_to Time.utc(2023, 6, 29) do
      user = create :user, insiders_status: :ineligible

      # Make the user eligible
      create :payments_payment, amount_in_cents: 100, user:, created_at: Time.utc(2022, 7, 23)

      User::Notification::CreateEmailOnly.expects(:defer).with(user, :eligible_for_insiders).once

      User::InsidersStatus::Update.(user)
    end
  end

  [
    %i[ineligible eligible_lifetime],
    %i[eligible eligible_lifetime],
    %i[active active_lifetime]
  ].each do |(current_status, expected_status)|
    test "#{current_status} -> eligible_lifetime" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible_lifetime)

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  [
    %i[eligible_lifetime eligible_lifetime],
    %i[active_lifetime active_lifetime]
  ].each do |(current_status, expected_status)|
    test "#{current_status} -> eligible_lifetime: No-op" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).never
      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  %i[ineligible eligible].each do |current_status|
    test "#{current_status} -> eligible_lifetime: notification created" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible_lifetime)

      User::Notification::CreateEmailOnly.expects(:defer).with(user, :eligible_for_lifetime_insiders).once

      User::InsidersStatus::Update.(user)
    end
  end

  test "active -> eligible_lifetime: notification created" do
    user = create :user, insiders_status: :active

    User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible_lifetime)

    # TODO: Make this Create.(...)
    User::Notification::CreateEmailOnly.expects(:defer).with(user, :upgraded_to_lifetime_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "active -> eligible_lifetime: lifetime insider badge awarded" do
    user = create :user, insiders_status: :active
    refute_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge # Sanity

    User::InsidersStatus::DetermineEligibilityStatus.expects(:call).returns(:eligible_lifetime)

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::LifetimeInsiderBadge
  end
end
