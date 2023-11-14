require 'test_helper'

class SerializeMentorRequestsTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create :concept_solution, exercise:, user: student
    request = create(:mentor_request, solution:)

    expected = [
      {
        uuid: request.uuid,

        track: { title: track.title },
        exercise: {
          title: exercise.title,
          icon_url: exercise.icon_url
        },
        student: {
          handle: student.handle,
          avatar_url: student.avatar_url
        },
        solution: {
          uuid: solution.uuid
        },
        updated_at: request.created_at.iso8601,

        have_mentored_previously: false,
        is_favorited: false,
        status: "First timer",
        tooltip_url: Exercism::Routes.api_mentoring_student_path(student, track_slug: "ruby"),

        url: Exercism::Routes.mentoring_request_url(request)
      }
    ]

    assert_equal expected, SerializeMentorRequests.(Mentor::Request.all, mentor)
  end

  test "mentored before" do
    student = create :user
    create :mentor_request, solution: create(:concept_solution, user: student)

    mentor = create :user
    relationship = create(:mentor_student_relationship, student:, mentor:)

    result = SerializeMentorRequests.(Mentor::Request.all, mentor)
    assert result[0][:have_mentored_previously]
    refute result[0][:is_favorited]

    relationship.update(favorited: true)
    result = SerializeMentorRequests.(Mentor::Request.all, mentor)
    assert result[0][:is_favorited]
  end

  test "status" do
    student = create :user
    mentor = create :user
    create :mentor_request, solution: create(:concept_solution, user: student)

    result = SerializeMentorRequests.(Mentor::Request.all, mentor)
    assert_equal "First timer", result[0][:status]

    create :mentor_discussion, solution: create(:practice_solution, user: student)

    result = SerializeMentorRequests.(Mentor::Request.all, mentor)
    assert_nil result[0][:status]
  end

  test "n+1s handled correctly" do
    mentor = create :user
    create_np1_data(mentor:)

    Bullet.profile do
      SerializeMentorRequests.(Mentor::Request.all, mentor)
    end
  end
end
