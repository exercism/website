require 'test_helper'

class SerializeMentorSessionDiscussionTest < ActiveSupport::TestCase
  test "for mentor" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :awaiting_mentor,
      solution: solution,
      mentor: mentor

    expected = {
      id: discussion.uuid,
      is_finished: false,
      links: {
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        finish: Exercism::Routes.finish_api_mentoring_discussion_path(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_path(discussion)
      }
    }

    assert_equal expected, SerializeMentorSessionDiscussion.(discussion, mentor)

    discussion.update(status: :mentor_finished)
    assert SerializeMentorSessionDiscussion.(discussion, mentor)[:is_finished]
  end

  test "for student" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :awaiting_mentor,
      solution: solution,
      mentor: mentor

    expected = {
      id: discussion.uuid,
      is_finished: false,
      links: {
        posts: Exercism::Routes.api_solution_discussion_posts_url(solution.uuid, discussion)
      }
    }

    assert_equal expected, SerializeMentorSessionDiscussion.(discussion, student)

    discussion.update(status: :student_finished)
    assert SerializeMentorSessionDiscussion.(discussion, student)[:is_finished]
  end
end
