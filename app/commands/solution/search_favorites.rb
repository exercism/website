class Solution::SearchFavorites
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil, per: nil, order: nil, criteria: nil, track_slug: nil)
    @user = user
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
    @order = order&.to_sym
    @criteria = criteria
    @track_slug = track_slug
  end

  def call
    @favorites = user.solution_stars.includes(:solution)

    filter_criteria!
    filter_track!

    solutions = @favorites.page(page).per(per).map(&:solution)

    Kaminari.paginate_array(solutions, total_count: @favorites.count).page(page).per(per)
  end

  private
  attr_reader :user, :per, :page, :order, :criteria, :track_slug, :solutions

  def filter_track!
    return unless track

    @favorites = @favorites.joins(solution: :exercise).
      where("exercises.track_id": track.id)
  end

  def filter_criteria!
    return if @criteria.blank?

    @favorites = @favorites.joins(solution: :user).where("users.handle LIKE ?", "%#{criteria}%")
  end

  memoize
  def track
    return nil if track_slug.blank?

    Track.find_by(slug: track_slug)
  end
end
