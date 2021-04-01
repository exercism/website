require 'test_helper'

class SerializeMentorRequestsTest < ActiveSupport::TestCase
  test "basic request" do
    mentee = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: mentee
    request = create :mentor_request, solution: solution
    mentor = create :user

    requests = Mentor::Request::Retrieve.(mentor: mentor)

    expected = [
      {
        id: request.uuid,

        track_title: track.title,
        track_icon_url: track.icon_url,
        exercise_title: exercise.title,

        mentee_handle: mentee.handle,
        mentee_avatar_url: mentee.avatar_url,
        updated_at: request.created_at.iso8601,

        is_starred: true,
        have_mentored_previously: true,
        status: "First timer",
        tooltip_url: "#",

        url: Exercism::Routes.mentoring_request_url(request)
      }
    ]

    assert_equal expected, SerializeMentorRequests.(requests)
  end
end
