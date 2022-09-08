class AssembleProfileTestimonialsList
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[page]
  end

  def call
    SerializePaginatedCollection.(
      testimonials.page(params[:page]).per(4),
      serializer: SerializeMentorTestimonials,
      meta: {
        unscoped_total: testimonials.count
      }
    )
  end

  memoize
  def testimonials
    user.mentor_testimonials.published
  end
end
