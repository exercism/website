class AssembleProfileTestimonialsList
  include Mandate

  initialize_with :user

  def call
    { testimonials: SerializeMentorTestimonials.(testimonials).sort_by { rand } }
  end

  memoize
  def testimonials
    user.mentor_testimonials.published
  end
end
