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

      User::InsidersStatus::Activate.(user)

      assert_equal expected, user.insiders_status
    end
  end

  test "notification is created when changing status to active" do
    user = create :user

    User::Notification::Create.expects(:call).with(user, :joined_insiders).once

    user.update(insiders_status: :eligible)
    User::InsidersStatus::Activate.(user)
  end

  test "notification is created when changing status to active_lifetime" do
    user = create :user, :admin

    User::Notification::Create.expects(:call).with(user, :joined_lifetime_insiders).once

    user.update(insiders_status: :eligible_lifetime)
    User::InsidersStatus::Activate.(user)
  end

  test "flair updated when changing status to active" do
    user = create :user, flair: nil, insiders_status: :eligible

    User::InsidersStatus::Activate.(user)

    assert_equal :insider, user.flair
  end

  %i[founder staff original_insider].each do |flair|
    test "flair not updated when changing status to active and current flair is #{flair}" do
      user = create :user, flair:, insiders_status: :eligible

      User::InsidersStatus::Activate.(user)

      assert_equal flair, user.flair
    end
  end
end
