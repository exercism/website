require 'test_helper'

class User::Notifications::JoinedPremiumNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedPremiumNotification.create!(user:, params: {})
    assert_equal "#{user.id}|joined_premium|", notification.uniqueness_key
  end
end
