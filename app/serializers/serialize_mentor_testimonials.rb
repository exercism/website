class SerializeMentorTestimonials
  include Mandate

  initialize_with :testimonials

  def call
    testimonials.
      map { |t| serialize_testimonial(t) }
  end

  private
  def serialize_testimonial(testimonial)
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
      created_at: testimonial.created_at.iso8601
    }
  end
end
