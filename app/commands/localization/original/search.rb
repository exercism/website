class Localization::Original::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil, per: nil, criteria: nil)
    @user = user

    @criteria = criteria
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
  end

  def call
    @translations = Localization::Translation.where(locale: locales)

    filter_criteria!

    # Get all of the english versions paginated.
    # We do an inner query so things like the criteria work on
    # the inner query.
    originals = Localization::Original.where(key: @translations.select(:key))

    paginated_originals = originals.page(page).per(per)

    Kaminari.paginate_array(
      paginated_originals,
      total_count: originals.count
    ).page(page).per(per)
  end

  # TODO: Drive this from the user's locales
  def locales = %i[en hu]

  private
  attr_reader :user, :per, :page, :criteria, :track_slug, :solutions

  def filter_criteria!
    return if @criteria.blank?

    @translations = @translations.where("translations.value LIKE ?", "%#{criteria}%")
  end

  memoize
  def track
    return nil if track_slug.blank?

    Track.find_by(slug: track_slug)
  end
end
