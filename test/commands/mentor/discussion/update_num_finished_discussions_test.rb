require 'test_helper'

class Mentor::Discussion::UpdateNumFinishedDiscussionsTest < ActiveSupport::TestCase
  test "updates num_finished_discussions" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    mentor = create :user
    other_mentor = create :user
    mentorship = create(:user_track_mentorship, user: mentor, track:)
    other_mentorship = create(:user_track_mentorship, user: other_mentor, track:)

    discussion_1 = create(:mentor_discussion, mentor:, status: :awaiting_student, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_1)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    discussion_2 = create(:mentor_discussion, mentor:, status: :awaiting_mentor, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_2)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    discussion_3 = create(:mentor_discussion, mentor:, status: :mentor_finished, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_3)
    assert_equal 0, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    discussion_4 = create(:mentor_discussion, mentor:, status: :finished, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_4)
    assert_equal 1, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    discussion_5 = create(:mentor_discussion, mentor:, status: :finished, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_5)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    # Sanity check: same mentor but different track
    discussion_6 = create :mentor_discussion, mentor:, status: :finished, track: other_track
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_6)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 0, other_mentorship.reload.num_finished_discussions

    # Sanity check: same track but different mentor
    discussion_7 = create(:mentor_discussion, mentor: other_mentor, status: :finished, track:)
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_7)
    assert_equal 2, mentorship.reload.num_finished_discussions
    assert_equal 1, other_mentorship.reload.num_finished_discussions
  end
end
