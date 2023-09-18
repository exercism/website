require 'test_helper'

class User::Notifications::AcquiredTrophyNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    track = create :track, slug: 'ruby', title: 'Ruby'
    trophy = create :mentored_trophy
    user_track_acquired_trophy = create(:user_track_acquired_trophy, user:, track:, trophy:)

    notification = User::Notifications::AcquiredTrophyNotification.create!(user:, params: { user_track_acquired_trophy: })
    assert_equal "#{user.id}|acquired_trophy|Track##{track.id}|Trophy##{trophy.id}", notification.uniqueness_key
    assert_equal "You've been awarded the Magnificent Mentee trophy on the Ruby track", notification.text
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?("/assets/graphics/trophy-mentored-")
    assert_equal "https://test.exercism.org/tracks/ruby#trophy-cabinet", notification.url
    assert_equal "/tracks/#{track.slug}#trophy-cabinet", notification.path
  end
end
