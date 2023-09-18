require 'test_helper'

class SerializeMentorDiscussionForStudentTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create :concept_solution, exercise:, user: student
    create(:iteration, solution:)
    discussion = create(:mentor_discussion,
      :awaiting_mentor,
      solution:,
      mentor:)
    create(:mentor_discussion_post, discussion:)
    create(:mentor_discussion_post, discussion:)

    output = mock
    SerializeMentorDiscussion.expects(:call).with(
      discussion,
      nil,
      discussion.finished_for_student?,
      discussion.posts.where(seen_by_student: false).exists?,
      {
        self: Exercism::Routes.track_exercise_mentor_discussion_url(discussion.track, discussion.exercise, discussion),
        posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion),
        finish: Exercism::Routes.finish_api_solution_discussion_url(discussion.solution.uuid, discussion.uuid)
      }
    ).returns(output)

    assert_equal output, SerializeMentorDiscussionForStudent.(discussion)
  end
end
