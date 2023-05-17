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

    # TODO: Make this Create.(...)
    User::Notification::CreateEmailOnly.expects(:defer).with(user, :expired_insiders).once

    User::InsidersStatus::Update.(user)
  end

  %i[ineligible eligible eligible_lifetime active_lifetime].each do |current_status|
    test "ineligible: notification not created when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "ineligible: set discord roles" do
    user = create :user, insiders_status: :unset

    User::SetDiscordRoles.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
  end

  test "ineligible: set discourse groups" do
    user = create :user, insiders_status: :unset

    User::SetDiscourseGroups.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
  end

  test "ineligible: user is premium until last payment date + 30 days if that is in the future" do
    freeze_time do
      user = create :user, insiders_status: :active, premium_until: Time.current
      create(:payments_payment, product: :premium, created_at: Time.current - 2.months, user:)
      last_payment = create(:payments_payment, product: :premium, created_at: Time.current - 20.days, user:)

      User::SetDiscourseGroups.stubs(:defer)

      perform_enqueued_jobs do
        User::InsidersStatus::Update.(user.reload)
      end

      assert_equal last_payment.created_at + 30.days, user.reload.premium_until
      assert user.premium?
    end
  end

  test "ineligible: user is no longer premium when last payment date + 30 days is not in the future" do
    user = create :user, insiders_status: :active, premium_until: Time.current
    create :payments_payment, product: :premium, created_at: Time.current - 2.months

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

      User::Notification::Create.expects(:defer).never

      User::InsidersStatus::Update.(user)
    end
  end

  test "eligible: notification created when current status is ineligible" do
    user = create :user, insiders_status: :ineligible

    # Make the user eligible
    user.update(active_donation_subscription: true)

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :eligible_for_insiders).once

    User::InsidersStatus::Update.(user)
  end

  test "eligible: set discord roles" do
    user = create :user, insiders_status: :ineligible

    # Make the user eligible
    user.update(active_donation_subscription: true)

    User::SetDiscordRoles.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
  end

  test "eligible: set discourse groups" do
    user = create :user, insiders_status: :ineligible

    # Make the user eligible
    user.update(active_donation_subscription: true)

    User::SetDiscourseGroups.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
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

  test "eligible_lifetime: insider badge awarded when current status is active" do
    user = create :user, insiders_status: :active

    User::SetDiscourseGroups.stubs(:defer)

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)
    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  test "eligible_lifetime: flair updated to lifetime_insider when current status is active" do
    user = create :user, insiders_status: :active

    User::SetDiscourseGroups.stubs(:defer)

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    User::InsidersStatus::Update.(user)

    assert_equal :lifetime_insider, user.flair
  end

  test "eligible_lifetime: give lifetime premium when current status is active" do
    user = create :user, insiders_status: :active

    User::SetDiscourseGroups.stubs(:defer)

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    # Sanity check
    refute user.premium?

    perform_enqueued_jobs do
      User::InsidersStatus::Update.(user)
    end

    assert user.reload.premium?
  end

  test "eligible_lifetime: set discourse groups" do
    user = create :user, insiders_status: :active

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    User::SetDiscourseGroups.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
  end

  test "eligible_lifetime: set discord roles" do
    user = create :user, insiders_status: :active

    # Make the user eligible
    user.update(reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD)

    User::SetDiscordRoles.expects(:defer).with(user)

    User::InsidersStatus::Update.(user)
  end
end
