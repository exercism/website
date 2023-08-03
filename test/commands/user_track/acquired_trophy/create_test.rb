require "test_helper"

class UserTrack::AcquiredTrophy::CreateTest < ActiveSupport::TestCase
  test "returns existing trophy" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    expected = create(:user_track_acquired_trophy, user:, trophy:)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    assert_equal expected, actual
  end

  test "creates new trophy" do
    user = create :user
    track = create :track
    trophy = create :mentored_trophy
    Track::Trophies::General::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(true)

    actual = UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    assert_equal user, actual.user
    assert_equal trophy, actual.trophy
  end

  test "fails if criteria are not met" do
    user = create :user
    track = create :track
    create :mentored_trophy
    Track::Trophies::General::MentoredTrophy.any_instance.expects(:award?).with(user, track).returns(false)

    assert_raises TrophyCriteriaNotFulfilledError do
      UserTrack::AcquiredTrophy::Create.(user, track, :general, :mentored)
    end
  end

  # test "Creates notification if key is present" do
  #   user = create :user
  #   force_award!(user)

  #   create :mentored_trophy
  #   notification_key = :some_key
  #   Trophys::ContributorTrophy.any_instance.stubs(notification_key:)
  #   User::Notification::Create.expects(:call).with(user, notification_key)

  #   UserTrack::AcquiredTrophy::Create.(user, :contributor)
  # end

  # test "Does not create notification if key is not present" do
  #   user = create :user
  #   force_award!(user)

  #   create :mentored_trophy
  #   notification_key = ""
  #   Trophys::ContributorTrophy.any_instance.stubs(notification_key:)
  #   User::Notification::Create.expects(:call).never

  #   UserTrack::AcquiredTrophy::Create.(user, :contributor)
  # end

  # test "Sends email if send_email_on_acquisition" do
  #   user = create :user
  #   force_award!(user)

  #   create :mentored_trophy
  #   Trophys::ContributorTrophy.any_instance.expects(:send_email_on_acquisition?).returns(true)
  #   User::Notification::CreateEmailOnly.expects(:call).with do |*params|
  #     assert_equal user, params[0]
  #     assert_equal :acquired_trophy, params[1]
  #     assert_equal :user_acquired_trophy, params[2].keys.first
  #     assert params[2].values.first.is_a?(User::AcquiredTrophy)
  #   end

  #   UserTrack::AcquiredTrophy::Create.(user, :contributor)
  # end

  # test "Does not send email if send_email_on_acquisition is false" do
  #   user = create :user
  #   force_award!(user)

  #   create :mentored_trophy
  #   Trophys::ContributorTrophy.any_instance.expects(:send_email_on_acquisition?).returns(false)
  #   User::Notification::CreateEmailOnly.expects(:call).never

  #   UserTrack::AcquiredTrophy::Create.(user, :contributor)
  # end

  # test "Does not send email if send_email_on_acquisition is true and send_email is false" do
  #   user = create :user
  #   force_award!(user)

  #   create :mentored_trophy
  #   Trophys::ContributorTrophy.any_instance.expects(:send_email_on_acquisition?).returns(true)
  #   User::Notification::CreateEmailOnly.expects(:call).never

  #   UserTrack::AcquiredTrophy::Create.(user, :contributor, send_email: false)
  # end

  # test "resets user cache" do
  #   user = create :user
  #   create :mentored_trophy
  #   Trophys::ContributorTrophy.any_instance.expects(:award?).with(user).returns(true)

  #   assert_user_data_cache_reset(user, :has_unrevealed_trophys?, true) do
  #     UserTrack::AcquiredTrophy::Create.(user, :contributor)
  #   end
  # end

  # def force_award!(user)
  #   Trophys::ContributorTrophy.any_instance.expects(:award?).with(user).returns(true)
  # end
end
