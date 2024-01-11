require "test_helper"

class Mentor::UpdateMentoredTracksTest < ActiveSupport::TestCase
  test "adds new mentored tracks" do
    mentor = create :user
    track = create :track

    assert_empty mentor.mentored_tracks

    Mentor::UpdateMentoredTracks.(mentor, [track])

    assert_equal [track], mentor.mentored_tracks
  end

  test "keeps existing tracks" do
    mentor = create :user
    track = create :track
    updated_at = Time.current - 2.weeks
    track_mentorship = create(:user_track_mentorship, track:, user: mentor, updated_at:)

    assert_equal [track], mentor.mentored_tracks

    Mentor::UpdateMentoredTracks.(mentor, [track])

    assert_equal [track], mentor.mentored_tracks
    assert_equal updated_at, track_mentorship.updated_at
  end

  test "removes tracks no longer being mentored" do
    mentor = create :user
    track = create :track
    updated_at = Time.current - 2.weeks
    track_mentorship = create(:user_track_mentorship, track:, user: mentor, updated_at:)

    assert_equal [track], mentor.mentored_tracks

    Mentor::UpdateMentoredTracks.(mentor, [])

    assert_empty mentor.mentored_tracks
    assert_raises ActiveRecord::RecordNotFound do
      track_mentorship.reload
    end
  end

  test "updates supermentor role" do
    mentor = create :user

    User::UpdateSupermentorRole.expects(:defer).with(mentor)

    Mentor::UpdateMentoredTracks.(mentor, [])
  end

  test "updates discord roles" do
    mentor = create :user

    User::SetDiscordRoles.expects(:defer).with(mentor)

    perform_enqueued_jobs do
      Mentor::UpdateMentoredTracks.(mentor, [])
    end
  end
end
