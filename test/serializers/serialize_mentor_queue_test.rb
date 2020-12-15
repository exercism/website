require 'test_helper'

class SerializeMentorQueueTest < ActiveSupport::TestCase
  test "basic request" do
    mentee = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: mentee
    request = create :solution_mentor_request, solution: solution
    mentor = create :user

    queue = Mentor::RetrieveQueue.(mentor)

    expected = {
      results: [
        {
          id: request.uuid,

          track_title: track.title,
          track_icon_url: track.icon_url,
          exercise_title: exercise.title,

          mentee_handle: mentee.handle,
          mentee_avatar_url: mentee.avatar_url,
          updated_at: request.created_at.to_i,

          is_starred: true,
          have_mentored_previously: true,
          status: "First timer",
          tooltip_url: "#",

          url: "https://test.exercism.io/mentor/requests/#{request.uuid}"
        }
      ],
      meta: { current: 1, total: 1 }
    }

    assert_equal expected, SerializeMentorQueue.(queue)
  end
end
