require "test_helper"

class UserTrack::AcquiredTrophy::CreateTest < ActiveSupport::TestCase
  test "returns existing trophy for specified track" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    expected = create(:user_track_acquired_trophy, user:, trophy:, track:)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
    assert_equal expected, actual
  end

  test "ignores same trophy for different track" do
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    trophy = create :mentored_trophy
    create(:user_track_acquired_trophy, user:, trophy:, track: other_track)

    assert_raises TrophyCriteriaNotFulfilledError do
      UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
    end
  end

  test "creates new trophy" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(true)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
    assert_equal user, actual.user
    assert_equal trophy, actual.trophy
  end

  test "fails if criteria are not met" do
    user = create :user
    track = create :track
    create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(false)

    assert_raises TrophyCriteriaNotFulfilledError do
      UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
    end
  end

  test "creates notification if key is present" do
    user = create :user
    track = create :track
    force_trophy!(user, track)

    create :mentored_trophy
    notification_key = :some_key
    Track::Trophies::MentoredTrophy.any_instance.stubs(notification_key:)
    User::Notification::Create.expects(:call).with(user, notification_key)

    UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
  end

  test "creates default notification if key is not present" do
    user = create :user
    track = create :track
    force_trophy!(user, track)
    create :mentored_trophy

    notification_key = ""
    Track::Trophies::MentoredTrophy.any_instance.stubs(notification_key:)
    User::Notification::Create.expects(:call).with do |actual_user, actual_slug, kwargs|
      assert_equal user, actual_user
      assert_equal :acquired_trophy, actual_slug
      refute_nil kwargs[:user_track_acquired_trophy]
    end

    UserTrack::AcquiredTrophy::Create.(user, track, :mentored)
  end

  def force_trophy!(user, track)
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(true)
  end
end
