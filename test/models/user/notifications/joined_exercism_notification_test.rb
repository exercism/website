require 'test_helper'

class User::Notifications::JoinedExercismNotificationTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetUrlHelper
  include Webpacker::Helper

  test "keys are valid" do
    user = create :user
    notification = User::Notifications::JoinedExercismNotification.create!(user: user, params: {})
    assert_equal "#{user.id}|joined_exercism|", notification.uniqueness_key
  end
end
