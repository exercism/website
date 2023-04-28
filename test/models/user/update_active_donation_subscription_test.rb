require 'test_helper'

class User::UpdateActiveDonationSubscriptionTest < ActiveSupport::TestCase
  test "sets active_donation_subscription to true if any active donation subscriptions exist" do
    user = create :user, active_donation_subscription: false
    create :donations_subscription, user:, status: :active

    User::UpdateActiveDonationSubscription.(user)

    assert user.active_donation_subscription
  end

  test "sets active_donation_subscription to false if no active donation subscriptions exist" do
    user = create :user, active_donation_subscription: false
    create :donations_subscription, user:, status: :canceled
    create :donations_subscription, user:, status: :overdue

    User::UpdateActiveDonationSubscription.(user)

    refute user.active_donation_subscription
  end

  test "sets active_donation_subscription to false if no donation subscriptions exist" do
    user = create :user, active_donation_subscription: true

    User::UpdateActiveDonationSubscription.(user)

    refute user.active_donation_subscription
  end

  test "trigger insiders status update" do
    user = create :user

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).once

    User::UpdateActiveDonationSubscription.(user)
  end
end
