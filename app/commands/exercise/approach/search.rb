class Exercise::Approach::Search
  include Mandate

  # Use class method rather than constant for
  # easier stubbing during testing
  def self.requests_per_page = 20

  initialize_with exercise_slug: nil, track_slug: nil, order: nil, page: 1

  def call
    @approaches = Exercise::Approach

    filter!
    sort!
    paginate!

    @approaches
  end

  private
  attr_reader :approaches

  def filter!
    filter_track! if track_slug.present?
    filter_exercise! if exercise_slug.present?
  end

  def filter_track!
    @approaches = @approaches.joins(exercise: :track).where(exercise: { tracks: { slug: track_slug } })
  end

  def filter_exercise!
    @approaches = @approaches.joins(:exercise).where(exercise: { slug: exercise_slug })
  end

  def sort!
    case order
    when "track"
      @approaches = @approaches.includes(:track).order('tracks.slug ASC')
    when "exercise"
      @approaches = @approaches.includes(:exercise).order('exercises.slug ASC')
    when "oldest"
      @approaches = @approaches.order(updated_at: :asc)
    else
      @approaches = @approaches.order(updated_at: :desc)
    end
  end

  def paginate!
    @approaches = @approaches.page(page).per(self.class.requests_per_page)
  end
end
