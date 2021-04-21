require 'test_helper'

class SerializeMentorRequestsTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    request = create :mentor_request, solution: solution

    expected = [
      {
        id: request.uuid,

        track_title: track.title,
        exercise_title: exercise.title,
        exercise_icon_url: exercise.icon_url,

        student_handle: student.handle,
        student_avatar_url: student.avatar_url,
        updated_at: request.created_at.iso8601,

        is_starred: true,
        have_mentored_previously: true,
        status: "First timer",
        tooltip_url: "#",

        url: Exercism::Routes.mentoring_request_url(request)
      }
    ]

    assert_equal expected, SerializeMentorRequests.(Mentor::Request.all)
  end
end
