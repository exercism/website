require 'test_helper'

class Mentor::UpdateNumFinishedDiscussionsTest < ActiveSupport::TestCase
  test "updates num_finished_discussions" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    mentor = create :user
    other_mentor = create :user
    mentorship = create(:user_track_mentorship, user: mentor, track:)
    other_mentorship = create(:user_track_mentorship, user: other_mentor, track:)

    create(:mentor_discussion, mentor:, status: :awaiting_student, track:)
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    create(:mentor_discussion, mentor:, status: :awaiting_mentor, track:)
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    create(:mentor_discussion, mentor:, status: :mentor_finished, track:)
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    create(:mentor_discussion, mentor:, status: :finished, track:)
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)
    assert_equal 1, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    create(:mentor_discussion, mentor:, status: :finished, track:)
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    # Sanity check: same mentor but different track
    create :mentor_discussion, mentor:, status: :finished, track: other_track
    Mentor::UpdateNumFinishedDiscussions.(mentor, other_track)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    # Sanity check: same track but different mentor
    create(:mentor_discussion, mentor: other_mentor, status: :finished, track:)
    Mentor::UpdateNumFinishedDiscussions.(other_mentor, track)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 1, other_mentorship.reload.num_finished_discussions
  end
end
