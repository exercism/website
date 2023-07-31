class Track::SearchSolutionsForMentoring
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 5

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, track, page: nil, paginated: true)
    @user = user
    @track = track
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = self.class.default_per
    @paginated = paginated
  end

  def call
    if user_track.mentoring_unlocked?
      @solutions = user.solutions.
        joins(exercise: :track).
        where("tracks.slug": track.slug).
        where(status: %i[iterated completed published]).
        where(mentoring_status: %i[none finished]).
        where.not("exercises.slug": "hello-world").
        order(id: :desc)
    else
      @solutions = ConceptSolution.none
    end

    paginated ? @solutions.page(page).per(per) : @solutions
  end

  private
  attr_reader :user, :track, :page, :per, :paginated

  memoize
  def user_track
    UserTrack.for(user, track)
  end
end
