require 'test_helper'

class SerializeMentorDiscussionTest < ActiveSupport::TestCase
  test "basic request" do
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
      status: discussion.status,
      finished_at: discussion.finished_at,
      finished_by: discussion.finished_by,

      track: {
        title: track.title,
        icon_url: track.icon_url
      },
      exercise: {
        title: exercise.title,
        icon_url: exercise.icon_url
      },

      student: {
        handle: student.handle,
        avatar_url: student.avatar_url,
        isStarred: true
      },

      mentor: {
        handle: mentor.handle,
        avatar_url: mentor.avatar_url
      },

      created_at: discussion.created_at.iso8601,
      updated_at: discussion.updated_at.iso8601,

      # TODO: Populate this
      is_finished: true,
      is_unread: true,
      posts_count: 4,

      links: {
        self: Exercism::Routes.mentoring_discussion_url(discussion)
      }
    }

    assert_equal expected, SerializeMentorDiscussion.(discussion)
  end
end
