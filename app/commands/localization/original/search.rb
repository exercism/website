class Localization::Original::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil, per: nil, criteria: nil, status: nil)
    @user = user

    @criteria = criteria
    @status = status
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
  end

  def call
    @translations = Localization::Translation.where(locale: locales)

    filter_criteria!
    filter_status!

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

  memoize
  def locales = user.translator_locales - [:en]

  private
  attr_reader :user, :per, :page, :criteria, :status, :track_slug, :solutions

  def filter_criteria!
    return if criteria.blank?

    @translations = @translations.where("localization_translations.value LIKE ?", "%#{criteria}%")
  end

  def filter_status!
    return if status.blank?

    @translations = @translations.where("localization_translations.status": status)
  end

  memoize
  def track
    return nil if track_slug.blank?

    Track.find_by(slug: track_slug)
  end
end
