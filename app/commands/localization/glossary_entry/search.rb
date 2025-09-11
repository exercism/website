class Localization::GlossaryEntry::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil, per: nil, criteria: nil, status: nil, locale: nil, excluded_ids: nil)
    @user = user

    @criteria = criteria
    @status = status
    @locale = locale
    @excluded_ids = excluded_ids
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
  end

  def call
    entries_from_glossary = search_glossary_entries
    entries_from_proposals = search_proposals

    # Combine results and ensure uniqueness by term+locale
    all_entries = combine_unique_entries(entries_from_glossary, entries_from_proposals)

    # Sort by locale then term
    sorted_entries = all_entries.sort_by { |e| [e.locale, e.term] }

    # Paginate
    Kaminari.paginate_array(
      sorted_entries,
      total_count: sorted_entries.count
    ).page(page).per(per)
  end

  memoize
  def locales = (user.translator_locales - [:en]).map(&:to_s)

  private
  attr_reader :user, :per, :page, :criteria, :status, :locale, :excluded_ids

  def search_glossary_entries
    entries = Localization::GlossaryEntry.where(locale: locales)

    if criteria.present?
      entries = entries.where(
        "localization_glossary_entries.term LIKE ? OR localization_glossary_entries.translation LIKE ?",
        "%#{criteria}%", "%#{criteria}%"
      )
    end

    entries = entries.where(status:) if status.present?
    entries = entries.where(locale:) if locale.present?
    entries = entries.where.not(id: excluded_ids) if excluded_ids.present?

    entries.to_a
  end

  def search_proposals
    # Only search addition proposals as they represent new entries
    proposals = Localization::GlossaryEntryProposal.addition.pending.where(locale: locales)

    if criteria.present?
      proposals = proposals.where(
        "localization_glossary_entry_proposals.term LIKE ? OR localization_glossary_entry_proposals.translation LIKE ?",
        "%#{criteria}%", "%#{criteria}%"
      )
    end

    proposals = proposals.where(locale:) if locale.present?

    # Convert proposals to entry-like objects for uniform handling
    proposals.map do |proposal|
      # Create a temporary entry object with the same interface
      entry = Localization::GlossaryEntry.new(
        id: proposal.id,
        uuid: proposal.uuid,
        term: proposal.term,
        locale: proposal.locale,
        translation: proposal.translation,
        llm_instructions: proposal.llm_instructions,
        status: :proposed
      )
      entry.readonly!
      entry
    end
  end

  def combine_unique_entries(glossary_entries, proposal_entries)
    # Create a hash to track unique entries by term+locale
    unique_entries = {}

    # Add glossary entries first (they take precedence)
    glossary_entries.each do |entry|
      key = "#{entry.locale}:#{entry.term}"
      unique_entries[key] = entry
    end

    # Add proposal entries only if no glossary entry exists for that term+locale
    proposal_entries.each do |entry|
      key = "#{entry.locale}:#{entry.term}"
      unique_entries[key] ||= entry
    end

    unique_entries.values
  end
end
