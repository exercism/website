require 'test_helper'

class User::Notifications::JoinedLifetimePremiumNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedLifetimePremiumNotification.create!(user:, params: {})
    assert_equal "#{user.id}|joined_lifetime_premium|", notification.uniqueness_key
  end
end
