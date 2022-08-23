class Exercise::Representation::Search
  include Mandate

  # Use class method rather than constant for easier stubbing during testing
  def self.requests_per_page = 20

  initialize_with criteria: nil, status: nil, mentor: nil, track: nil, order: :most_submissions,
    page: 1, paginated: true, sorted: true, only_mentored_solutions: false do
    @status = status.try(&:to_sym)
    @order = order.try(&:to_sym)
  end

  def call
    @representations = Exercise::Representation.joins(exercise: :track)
    filter_status!
    filter_mentor!
    filter_track!
    filter_criteria!
    filter_only_mentored_solutions!
    sort! if sorted
    paginate! if paginated
    @representations
  end

  private
  def filter_status!
    return if status.blank?

    case status
    when :without_feedback
      @representations = @representations.without_feedback
    when :with_feedback
      @representations = @representations.with_feedback
    end
  end

  def filter_mentor!
    return if mentor.blank?

    case status
    when :without_feedback
      @representations = @representations.track_mentored_by(mentor)
    when :with_feedback
      @representations = @representations.edited_by(mentor)
    end
  end

  def filter_track!
    return if track.blank?

    @representations = @representations.for_track(track)
  end

  def filter_criteria!
    return if criteria.blank?

    @representations = @representations.where('exercises.title LIKE ?', "%#{criteria}%").
      or(@representations.where('exercises.slug LIKE ?', "%#{criteria}%"))
  end

  def filter_only_mentored_solutions!
    return unless only_mentored_solutions

    @representations = @representations.mentored_by(mentor)
  end

  def sort!
    case order
    when :most_recent
      @representations = @representations.order(last_submitted_at: :desc)
    when :most_submissions
      @representations = @representations.order(num_submissions: :desc)
    end
  end

  def paginate!
    @representations = @representations.page(page).per(self.class.requests_per_page)
  end
end
