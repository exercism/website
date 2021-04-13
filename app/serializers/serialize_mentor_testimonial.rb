class SerializeMentorTestimonial
  include Mandate

  initialize_with :testimonial

  def call
    {
      id: testimonial.uuid,
      content: testimonial.content,
      student: {
        avatar_url: testimonial.student.avatar_url,
        handle: testimonial.student.handle
      },
      exercise: {
        title: testimonial.exercise.title,
        icon_url: testimonial.exercise.icon_url
      },
      track: {
        title: testimonial.track.title,
        icon_url: testimonial.track.icon_url
      },
      is_revealed: testimonial.revealed?,
      created_at: testimonial.created_at.iso8601,
      links: {
        reveal: Exercism::Routes.reveal_api_mentoring_testimonial_url(testimonial.uuid)
      }
    }
  end
end
