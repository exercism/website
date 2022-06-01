require 'test_helper'

class User::Notifications::JoinedExercismNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedExercismNotification.create!(user:, params: {})
    assert_equal "#{user.id}|joined_exercism|", notification.uniqueness_key
  end
end
