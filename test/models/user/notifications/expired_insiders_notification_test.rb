require 'test_helper'

class User::Notifications::ExpiredInsidersNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::ExpiredInsidersNotification.create!(user:, params: {})
    assert_equal "#{user.id}|expired_insiders|", notification.uniqueness_key
  end
end
