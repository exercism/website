class Exercise::Representation::Search
  include Mandate

  # Use class method rather than constant for easier stubbing during testing
  def self.requests_per_page = 20

  initialize_with with_feedback: Mandate::NO_DEFAULT, mentor: Mandate::NO_DEFAULT, criteria: nil, track: nil,
    order: :most_submissions, page: 1, paginated: true, sorted: true, only_mentored_solutions: false do
    @order = order.try(&:to_sym)
  end

  def call
    @representations = Exercise::Representation.
      includes(:exercise, :track).
      where('num_submissions > 1')
    filter_with_feedback!
    filter_track!
    filter_exercises!
    filter_only_mentored_solutions!
    sort! if sorted
    paginate! if paginated
    @representations
  end

  private
  def filter_with_feedback!
    if with_feedback
      @representations = @representations.with_feedback_by(mentor)
    else
      @representations = @representations.without_feedback
    end
  end

  def filter_track!
    return if track.blank?

    # If we're filtering on exercises, we'll apply the track filter on the exercises
    # and not on the representations, as the latter kills MySQL performance
    return if filter_exercises?

    @representations = @representations.for_track(track)
  end

  def filter_exercises!
    return unless filter_exercises?

    @representations = @representations.where(exercise_id: exercise_ids)
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

  memoize
  def exercise_ids
    relation = Exercise.where('title LIKE ?', "%#{criteria}%").
      or(Exercise.where('slug LIKE ?', "%#{criteria}%"))
    relation = relation.where(track_id: track) if track
    relation.pluck(:id)
  end

  memoize
  def filter_exercises?
    # Check criteria here, not exercise_ids. If we check exercise_ids
    # then we'll get everything back if no exercises match the criteria
    criteria.present? && criteria.strip.length >= MIN_CRITERIA_LENGTH
  end

  MIN_CRITERIA_LENGTH = 3
  private_constant :MIN_CRITERIA_LENGTH
end
