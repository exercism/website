require 'test_helper'

class User::InsidersStatus::ActivateTest < ActiveSupport::TestCase
  %i[ineligible active active_lifetime].each do |current_status|
    test "don't change status when current insiders_status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::Activate.(user)

      assert_equal current_status, user.reload.insiders_status
    end

    test "don't create notification when current insiders_status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::Notification::CreateEmailOnly.expects(:defer).never

      User::InsidersStatus::Activate.(user)
    end

    test "don't award badge when current insiders_status is #{current_status}" do
      user = create :user, insiders_status: current_status

      perform_enqueued_jobs do
        User::InsidersStatus::Activate.(user)
      end

      refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge
    end
  end

  test "change status to active_lifetime when current insiders_status is eligible_lifetime" do
    user = create :user, insiders_status: :eligible_lifetime

    User::InsidersStatus::Activate.(user)

    assert_equal :active_lifetime, user.reload.insiders_status
  end

  test "create notification when current insiders_status is eligible_lifetime" do
    user = create :user, insiders_status: :eligible_lifetime

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :joined_lifetime_insiders).once

    User::InsidersStatus::Activate.(user)
  end

  test "flair set to insider updated when changing status to active" do
    user = create :user, flair: nil, insiders_status: :eligible

    User::InsidersStatus::Activate.(user)

    assert_equal :insider, user.flair
  end

  test "flair set to lifetime_insider updated when changing status to active_lifetime" do
    user = create :user, flair: nil, insiders_status: :eligible_lifetime

    User::InsidersStatus::Activate.(user)

    assert_equal :lifetime_insider, user.flair
  end

  %i[eligible eligible_lifetime].each do |insiders_status|
    test "flair not updated when insiders status is #{insiders_status} and user has founder flair" do
      user = create(:user, :founder, flair: :founder, insiders_status:)

      User::InsidersStatus::Activate.(user)

      assert_equal :founder, user.flair
    end

    test "flair not updated when insiders status is #{insiders_status} and user has staff flair" do
      user = create(:user, :staff, flair: :staff, insiders_status:)

      User::InsidersStatus::Activate.(user)

      assert_equal :staff, user.flair
    end
  end

  test "set discord roles when changing status to active" do
    user = create :user

    User::SetDiscordRoles.expects(:defer).with(user)

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "set discord roles when changing status to active_lifetime" do
    user = create :user, :admin

    User::SetDiscourseGroups.expects(:defer)

    user.update(insiders_status: :eligible_lifetime)
    User::InsidersStatus::Activate.(user)
  end

  test "set discourse groups when changing status to active" do
    user = create :user

    User::SetDiscourseGroups.expects(:defer).with(user)

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "set discourse groups when changing status to active_lifetime" do
    user = create :user, :admin

    User::SetDiscourseGroups.expects(:defer).with(user)

    user.update(insiders_status: :eligible_lifetime)
    User::InsidersStatus::Activate.(user)
  end

  test "award lifetime insider badge when current insiders_status is eligible_lifetime" do
    user = create :user, insiders_status: :eligible_lifetime

    User::SetDiscordRoles.stubs(:defer)
    User::SetDiscourseGroups.stubs(:defer)

    badges = user.reload.badges.map(&:class)
    refute_includes badges, Badges::InsiderBadge
    refute_includes badges, Badges::LifetimeInsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Activate.(user)
    end

    badges = user.reload.badges.map(&:class)
    assert_includes badges, Badges::InsiderBadge
    assert_includes badges, Badges::LifetimeInsiderBadge
  end

  test "change status to active when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    User::InsidersStatus::Activate.(user)

    assert_equal :active, user.reload.insiders_status
  end

  test "create notification when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :joined_insiders).once

    User::InsidersStatus::Activate.(user)
  end

  test "award insider badge when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    User::SetDiscordRoles.stubs(:defer)
    User::SetDiscourseGroups.stubs(:defer)

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Activate.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end
end
