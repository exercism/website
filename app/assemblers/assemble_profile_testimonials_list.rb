class AssembleProfileTestimonialsList
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[page]
  end

  def call
    SerializePaginatedCollection.(
      paginated_testimonials,
      serializer: SerializeMentorTestimonials,
      meta: {
        unscoped_total: testimonials.count
      }
    )
  end

  memoize
  def paginated_testimonials
    page = testimonials.order(id: :desc).page(params[:page]).per(1)
    return page unless params[:uuid]
    return page if page.map(&:uuid).include?(params[:uuid])

    selected = user.mentor_testimonials.published.find_by(uuid: params[:uuid])
    return page unless selected

    (page + [selected])
  end

  def testimonials
    user.mentor_testimonials.published
  end
end
