require "test_helper"

class UserTrack::AcquiredTrophy::CreateTest < ActiveSupport::TestCase
  test "returns existing trophy for specified track" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    expected = create(:user_track_acquired_trophy, user:, trophy:, track:)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    assert_equal expected, actual
  end

  test "ignores same trophy for different track" do
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    trophy = create :mentored_trophy
    create(:user_track_acquired_trophy, user:, trophy:, track: other_track)

    assert_raises TrophyCriteriaNotFulfilledError do
      UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    end
  end

  test "creates new trophy" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(true)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    assert_equal user, actual.user
    assert_equal trophy, actual.trophy
  end

  test "fails if criteria are not met" do
    user = create :user
    track = create :track
    create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(false)

    assert_raises TrophyCriteriaNotFulfilledError do
      UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
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

    UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
  end

  test "Does not create notification if key is not present" do
    user = create :user
    track = create :track
    force_trophy!(user, track)

    create :mentored_trophy
    notification_key = ""
    Track::Trophies::MentoredTrophy.any_instance.stubs(notification_key:)
    User::Notification::Create.expects(:call).never

    UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
  end

  test "Sends email if send_email_on_acquisition" do
    user = create :user
    track = create :track
    force_trophy!(user, track)

    create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:send_email_on_acquisition?).returns(true)
    User::Notification::CreateEmailOnly.expects(:call).with do |*params|
      assert_equal user, params[0]
      assert_equal :acquired_trophy, params[1]
      assert_equal :user_track_acquired_trophy, params[2].keys.first
      assert params[2].values.first.is_a?(UserTrack::AcquiredTrophy)
    end

    UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
  end

  test "Does not send email if send_email_on_acquisition is false" do
    user = create :user
    track = create :track
    force_trophy!(user, track)

    create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:send_email_on_acquisition?).returns(false)
    User::Notification::CreateEmailOnly.expects(:call).never

    UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
  end

  test "Does not send email if send_email_on_acquisition is true and send_email is false" do
    user = create :user
    track = create :track
    force_trophy!(user, track)

    create :mentored_trophy
    Track::Trophies::MentoredTrophy.any_instance.expects(:send_email_on_acquisition?).returns(true)
    User::Notification::CreateEmailOnly.expects(:call).never

    UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored, send_email: false)
  end

  def force_trophy!(user, track)
    Track::Trophies::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(true)
  end
end
