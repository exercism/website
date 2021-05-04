class SerializeMentorTestimonials
  include Mandate

  initialize_with :testimonials

  def call
    testimonials.
      includes(:student, :mentor, :exercise, :track).
      map { |t| SerializeMentorTestimonial.(t) }
  end
end
