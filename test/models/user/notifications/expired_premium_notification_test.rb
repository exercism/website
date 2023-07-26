require 'test_helper'

class User::Notifications::ExpiredPremiumNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::ExpiredPremiumNotification.create!(user:, params: {})
    assert_equal "#{user.id}|expired_premium|", notification.uniqueness_key
  end
end
