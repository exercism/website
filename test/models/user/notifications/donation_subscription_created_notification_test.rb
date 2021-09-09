require 'test_helper'

class User::Notifications::DonationSubscriptionCreatedNotificationTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetUrlHelper
  include Webpacker::Helper

  test "keys are valid" do
    user = create :user
    payment = create :donation_payment, user: user

    notification = User::Notifications::DonationSubscriptionCreatedNotification.create!(user: user, params: { payment: payment })
    assert_equal "#{user.id}|acquired_badge|Badge##{badge.id}", notification.uniqueness_key
  end
end
