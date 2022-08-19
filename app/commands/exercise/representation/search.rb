class Exercise::Representation::Search
  include Mandate

  # Use class method rather than constant for easier stubbing during testing
  def self.requests_per_page = 20

  def initialize(criteria: nil, status: nil, mentor: nil, track: nil, order: :most_submissions,
                 page: 1, paginated: true, sorted: true)
    @criteria = criteria
    @status = status.try(&:to_sym)
    @mentor = mentor
    @track = track
    @order = order.try(&:to_sym)
    @page = page
    @paginated = paginated
    @sorted = sorted
  end

  def call
    @representations = Exercise::Representation.joins(exercise: :track)
    filter_status!
    filter_mentor!
    filter_track!
    filter_criteria!
    sort! if sorted
    paginate! if paginated
    @representations
  end

  private
  attr_reader :criteria, :status, :mentor, :track, :order, :page, :paginated, :sorted

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
      @representations = @representations.mentored_by_mentor(mentor)
    when :with_feedback
      @representations = @representations.edited_by_mentor(mentor)
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
