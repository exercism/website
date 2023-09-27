require "test_helper"

class Mentor::SupermentorTest < ActiveSupport::TestCase
  test "earned_automator_status_for_track?" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    mentor = create :user
    other_mentor = create :user
    mentorship = create(:user_track_mentorship, user: mentor, track:)

    # Sanity check: not mentored anything
    refute Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)

    # Sanity check: ignore other user's track mentorships
    create(:user_track_mentorship, num_finished_discussions: 150, user: other_mentor, track:)
    refute Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)

    # Sanity check: ignore other track's mentorships
    create :user_track_mentorship, num_finished_discussions: 177, user: mentor, track: other_track
    refute Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)

    # Sanity check: mentored too few students
    mentorship.update(num_finished_discussions: 80)
    refute Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)

    # Sanity check: satisfactiong rating too low
    mentorship.update(num_finished_discussions: 105)
    mentor.data.update!(cache: { 'mentor_satisfaction_percentage' => 80 })
    refute Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)

    # Requirements met
    mentor.data.update!(cache: { 'mentor_satisfaction_percentage' => 96 })
    assert Mentor::Supermentor.earned_automator_status_for_track?(mentor, track)
  end
end
