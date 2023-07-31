require 'test_helper'

class User::Notifications::NudgeToRequestMentoringNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    track = create :track

    notification = User::Notifications::NudgeToRequestMentoringNotification.create!(user:, track:)

    url = Exercism::Routes.track_url(track, notification_uuid: notification.uuid, anchor: "mentoring")
    assert_equal "#{user.id}|nudge_to_request_mentoring|", notification.uniqueness_key
    assert_equal "<strong>It's time to get mentored!</strong> Learning with our mentors is an amazing way to level up your knowledge, and it's 100% free. Choose one of your solutions to begin.", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?('/assets/icons/mentoring-gradient-')
    assert_equal url, notification.url
  end
end
