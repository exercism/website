require 'test_helper'

class Mentor::Discussion::UpdateNumFinishedDiscussionsTest < ActiveSupport::TestCase
  test "updates count" do
    mentor = create :user
    mentorship = create :user_track_mentorship, user: mentor

    discussion_1 = create :mentor_discussion, mentor: mentor, status: :awaiting_student
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_1)
    assert_equal 0, mentorship.reload.num_finished_discussions

    discussion_2 = create :mentor_discussion, mentor: mentor, status: :awaiting_mentor
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_2)
    assert_equal 0, mentorship.reload.num_finished_discussions

    discussion_3 = create :mentor_discussion, mentor: mentor, status: :mentor_finished
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_3)
    assert_equal 0, mentorship.reload.num_finished_discussions

    discussion_4 = create :mentor_discussion, mentor: mentor, status: :finished
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_4)
    assert_equal 1, mentorship.reload.num_finished_discussions

    discussion_5 = create :mentor_discussion, mentor: mentor, status: :finished
    Mentor::Discussion::UpdateNumFinishedDiscussions.(discussion_5)
    assert_equal 2, mentorship.reload.num_finished_discussions
  end
end
