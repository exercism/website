require 'test_helper'

class User::Notifications::JoinedLifetimeInsidersNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedLifetimeInsidersNotification.create!(user:, params: {})
    assert_equal "#{user.id}|joined_lifetime_insiders|", notification.uniqueness_key
  end
end
