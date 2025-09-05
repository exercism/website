class Localization::GlossaryEntry::Search
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
    @glossary_entries = Localization::GlossaryEntry.where(locale: locales)

    filter_criteria!
    filter_status!

    paginated_glossary_entries = @glossary_entries.page(page).per(per)

    Kaminari.paginate_array(
      paginated_glossary_entries,
      total_count: @glossary_entries.count
    ).page(page).per(per)
  end

  memoize
  def locales = user.translator_locales - [:en]

  private
  attr_reader :user, :per, :page, :criteria, :status

  def filter_criteria!
    return if criteria.blank?

    @glossary_entries = @glossary_entries.where(
      "localization_glossary_entries.term LIKE ? OR localization_glossary_entries.translation LIKE ?",
      "%#{criteria}%", "%#{criteria}%"
    )
  end

  def filter_status!
    return if status.blank?

    @glossary_entries = @glossary_entries.where("localization_glossary_entries.status": status)
  end
end
