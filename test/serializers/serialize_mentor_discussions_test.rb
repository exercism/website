require 'test_helper'

class SerializeMentorDiscussionsTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :requires_mentor_action,
      solution: solution,
      mentor: mentor

    discussions = Mentor::Discussion::Retrieve.(mentor, page: 1)

    expected = [
      {
        id: discussion.uuid,

        track_title: track.title,
        track_icon_url: track.icon_url,
        exercise_title: exercise.title,

        student_handle: student.handle,
        student_avatar_url: student.avatar_url,
        updated_at: discussion.created_at.iso8601,

        is_starred: true,

        # TODO: Populate this
        posts_count: 4,

        url: Exercism::Routes.mentoring_discussion_url(discussion)
      }
    ]

    assert_equal expected, SerializeMentorDiscussions.(discussions)
  end
end
