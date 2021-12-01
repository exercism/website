require 'test_helper'

class User::Notifications::NudgeToRequestMentoringNotificationTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetUrlHelper
  include Webpacker::Helper

  test "keys are valid" do
    user = create :user
    track = create :track

    notification = User::Notifications::NudgeToRequestMentoringNotification.create!(user: user, track: track)

    url = Exercism::Routes.track_url(track, notification_uuid: notification.uuid, anchor: "mentoring")
    icon = asset_pack_url(
      "media/images/icons/mentoring-gradient.svg",
      host: Rails.application.config.action_controller.asset_host
    )

    assert_equal "#{user.id}|nudge_to_request_mentoring|", notification.uniqueness_key
    assert_equal "<strong>It's time to get mentored!</strong> Learning with our mentors is an amazing way to level up your knowledge, and it's 100% free. Choose one of your solutions to begin.", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert_equal icon, notification.image_url
    assert_equal url, notification.url
  end
end
