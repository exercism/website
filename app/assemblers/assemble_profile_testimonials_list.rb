class AssembleProfileTestimonialsList
  include Mandate

  initialize_with :user, :params

  # Use class method rather than constant for
  # easier stubbing during testing
  def self.testimonials_per_page = 64

  def self.keys = %i[page]

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
    page = testimonials.order(id: :desc).page(params[:page]).per(self.class.testimonials_per_page)
    return page unless params[:uuid]

    page_uuids = page.map(&:uuid)
    return page if page_uuids.include?(params[:uuid])

    selected = user.mentor_testimonials.published.find_by(uuid: params[:uuid])
    return page unless selected

    page_uuids.unshift(selected.uuid) # Show selected testimonial first

    testimonials.where(uuid: page_uuids).
      order(Arel.sql("FIND_IN_SET(uuid, '#{page_uuids.join(',')}')")).
      page(page.current_page).per(page.size + 1)
  end

  def testimonials = user.mentor_testimonials.published
end
