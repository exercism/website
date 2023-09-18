require 'test_helper'

class SerializeMentorDiscussionTest < ActiveSupport::TestCase
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

    is_finished = mock
    is_unread = mock
    student_favorited = mock
    links = mock

    expected = {
      uuid: discussion.uuid,
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
        flair: student.flair,
        avatar_url: student.avatar_url,
        is_favorited: student_favorited
      },

      mentor: {
        handle: mentor.handle,
        flair: mentor.flair,
        avatar_url: mentor.avatar_url
      },

      created_at: discussion.created_at.iso8601,
      updated_at: discussion.updated_at.iso8601,

      is_finished:,
      is_unread:,
      posts_count: 2,
      iterations_count: 1,
      links:
    }

    assert_equal expected, SerializeMentorDiscussion.(
      discussion,
      student_favorited,
      is_finished,
      is_unread,
      links
    )
  end
end
