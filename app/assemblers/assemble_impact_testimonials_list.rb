class AssembleImpactTestimonialsList
  include Mandate

  initialize_with :params

  def self.keys
    %i[page]
  end

  def call
    SerializePaginatedCollection.(
      testimonials.page(params[:page]).per(64),
      serializer: SerializeMentorTestimonials,
      meta: {
        unscoped_total: testimonials.count
      }
    )
  end

  memoize
  def testimonials
    Mentor::Testimonial.published.order('id desc')
  end
end
