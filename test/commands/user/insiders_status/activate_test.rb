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

      User::Notification::Create.expects(:call).never

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

    User::SetDiscourseGroups.stubs(:call)
    User::Notification::Create.expects(:call).with(user, :joined_lifetime_insiders).once

    User::InsidersStatus::Activate.(user)
  end

  test "set discord roles when changing status to active" do
    user = create :user

    User::SetDiscourseGroups.stubs(:call)
    User::SetDiscordRoles.expects(:call).with(user)

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "set discord roles when changing status to active_lifetime" do
    user = create :user, :admin

    User::SetDiscourseGroups.stubs(:call)
    User::SetDiscordRoles.expects(:call).with(user)

    user.update(insiders_status: :eligible_lifetime)
    User::InsidersStatus::Activate.(user)
  end

  test "set discourse groups when changing status to active" do
    user = create :user

    User::SetDiscourseGroups.expects(:call).with(user)

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "set discourse groups when changing status to active_lifetime" do
    user = create :user, :admin

    User::SetDiscourseGroups.expects(:call).with(user)

    user.update(insiders_status: :eligible_lifetime)
    User::InsidersStatus::Activate.(user)
  end

  test "award badge when current insiders_status is eligible_lifetime" do
    user = create :user, insiders_status: :eligible_lifetime

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Activate.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end

  test "change status to active when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    User::InsidersStatus::Activate.(user)

    assert_equal :active, user.reload.insiders_status
  end

  test "create notification when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    User::Notification::Create.expects(:call).with(user, :joined_insiders).once

    User::InsidersStatus::Activate.(user)
  end

  test "award badge when current insiders_status is eligible" do
    user = create :user, insiders_status: :eligible

    refute_includes user.reload.badges.map(&:class), Badges::InsiderBadge

    perform_enqueued_jobs do
      User::InsidersStatus::Activate.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::InsiderBadge
  end
end
