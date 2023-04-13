require 'test_helper'

class User::InsidersStatus::ActivateTest < ActiveSupport::TestCase
  %i[ineligible active active_lifetime].each do |current_status|
    test "don't change status when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::Activate.(user)

      assert_equal current_status, user.insiders_status
    end

    test "don't create notification when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::Notification::Create.expects(:call).with(user, :joined_insiders).never
      User::Notification::Create.expects(:call).with(user, :joined_lifetime_insiders).never

      User::InsidersStatus::Activate.(user)
    end
  end

  [%i[eligible active], %i[eligible_lifetime active_lifetime]].each do |(current, expected)|
    test "change status to #{expected} when current status is #{current}" do
      user = create :user, insiders_status: current
      User::SetDiscourseGroups.stubs(:call)

      User::InsidersStatus::Activate.(user)

      assert_equal expected, user.insiders_status
    end
  end

  test "notification is created when changing status to active" do
    user = create :user

    User::SetDiscourseGroups.stubs(:call)
    User::Notification::Create.expects(:call).with(user, :joined_insiders).once

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "notification is created when changing status to active_lifetime" do
    user = create :user, :admin

    User::SetDiscourseGroups.stubs(:call)
    User::Notification::Create.expects(:call).with(user, :joined_lifetime_insiders).once

    user.update(insiders_status: :eligible_lifetime)
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
end
