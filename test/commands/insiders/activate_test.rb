require 'test_helper'

class Insiders::ActivateTest < ActiveSupport::TestCase
  %i[ineligible active expired lifetime_active].each do |current_status|
    test "don't change status when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      Insiders::Activate.(user)

      assert_equal current_status, user.insiders_status
    end

    test "don't create notification when current status is #{current_status}" do
      user = create :user, insiders_status: current_status

      User::Notification::Create.expects(:call).with(user, :joined_insiders).never

      Insiders::Activate.(user)
    end
  end

  test "change status to active when current status is eligible" do
    user = create :user, insiders_status: :eligible

    Insiders::Activate.(user)

    assert_equal :active, user.insiders_status
  end

  test "notification is created when changing status to active" do
    user = create :user, insiders_status: :eligible

    User::Notification::Create.expects(:call).with(user, :joined_insiders).once

    Insiders::Activate.(user)
  end
end
