require 'test_helper'

class SerializeMentorInboxTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :solution_mentor_discussion,
      :requires_mentor_action,
      solution: solution,
      mentor: mentor

    inbox = Mentor::RetrieveInbox.(mentor)

    expected = {
      results: [
        {
          id: discussion.uuid,

          track_title: track.title,
          track_icon_url: track.icon_url,
          exercise_title: exercise.title,

          mentee_handle: student.handle,
          mentee_avatar_url: student.avatar_url,
          updated_at: discussion.created_at.to_i,

          is_starred: true,

          # TODO: Populate this
          posts_count: 4,

          url: "https://test.exercism.io/mentor/discussions/#{discussion.uuid}"
        }
      ],
      meta: { current: 1, total: 1 }
    }

    assert_equal expected, SerializeMentorInbox.(inbox)
  end
end
