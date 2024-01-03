require 'test_helper'

class SerializeMentorTestimonialsTest < ActiveSupport::TestCase
  test "basic testimonial" do
    student = create :user, handle: "student"
    mentor = create :user, handle: "mentor"
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    discussion = create(:mentor_discussion, solution:)
    testimonial = create(:mentor_testimonial, content: "Great mentor!", student:, mentor:, discussion:)

    expected = [
      {
        uuid: testimonial.uuid,
        content: "Great mentor!",
        student: {
          avatar_url: student.avatar_url,
          handle: "student",
          flair: student&.flair
        },
        mentor: {
          avatar_url: mentor.avatar_url,
          handle: "mentor",
          flair: mentor&.flair
        },
        exercise: {
          title: exercise.title,
          icon_url: exercise.icon_url
        },
        track: {
          title: track.title,
          icon_url: track.icon_url
        },
        is_revealed: false,
        created_at: testimonial.created_at.iso8601,
        links: {
          self: Exercism::Routes.testimonials_profile_url(testimonial.mentor.handle, uuid: testimonial.uuid),
          reveal: Exercism::Routes.reveal_api_mentoring_testimonial_url(testimonial.uuid),
          delete: Exercism::Routes.api_mentoring_testimonial_url(testimonial.uuid)
        }
      }
    ]

    assert_equal expected, SerializeMentorTestimonials.(Mentor::Testimonial.all)
  end
end
