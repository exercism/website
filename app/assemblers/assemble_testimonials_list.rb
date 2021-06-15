class AssembleTestimonialsList
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[criteria order track page]
  end

  def call
    SerializePaginatedCollection.(testimonials, serializer: SerializeMentorTestimonials)
  end

  memoize
  def testimonials
    Mentor::Testimonial::Retrieve.(
      mentor: user,
      criteria: params[:criteria],
      order: params[:order],
      track_slug: params[:track],
      page: params[:page],
      include_unrevealed: true
    )
  end
end
