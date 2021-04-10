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
      id: testimonial.uuid
    }
  end
end
