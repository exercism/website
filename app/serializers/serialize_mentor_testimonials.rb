class SerializeMentorTestimonials
  include Mandate

  initialize_with :testimonials

  def call
    testimonials.
      includes(
        :mentor, :exercise, :track,
        student: :avatar_attachment
      ).
      map { |t| SerializeMentorTestimonial.(t) }
  end
end
