require 'test_helper'

class User::Notifications::JoinedInsidersNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedInsidersNotification.create!(user:, params: {})
    assert_equal "#{user.id}|joined_insiders|", notification.uniqueness_key
  end
end
