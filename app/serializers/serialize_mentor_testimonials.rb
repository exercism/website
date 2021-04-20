class SerializeMentorTestimonials
  include Mandate

  initialize_with :testimonials

  def call
    testimonials.map { |t| SerializeMentorTestimonial.(t) }
  end
end
