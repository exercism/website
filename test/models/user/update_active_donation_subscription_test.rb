require 'test_helper'

class User::UpdateActiveDonationSubscriptionTest < ActiveSupport::TestCase
  test "sets active_donation_subscription to true if any active donation subscriptions exist" do
    user = create :user, active_donation_subscription: false
    create :payments_subscription, :donation, user:, status: :active

    User::UpdateActiveDonationSubscription.(user)

    assert user.active_donation_subscription?
  end

  test "sets active_donation_subscription to false if no active donation subscriptions exist" do
    user = create :user, active_donation_subscription: false
    create :payments_subscription, :donation, user:, status: :canceled
    create :payments_subscription, :donation, user:, status: :overdue
    create :payments_subscription, :premium, user:, status: :active

    User::UpdateActiveDonationSubscription.(user)

    refute user.active_donation_subscription?
  end

  test "sets active_donation_subscription to false if no donation subscriptions exist" do
    user = create :user, active_donation_subscription: true

    User::UpdateActiveDonationSubscription.(user)

    refute user.active_donation_subscription?
  end

  test "trigger insiders status update" do
    user = create :user

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).once

    User::UpdateActiveDonationSubscription.(user)
  end
end
