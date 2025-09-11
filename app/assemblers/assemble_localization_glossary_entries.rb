class AssembleLocalizationGlossaryEntries
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[criteria status page excluded_ids]
  end

  def call
    SerializePaginatedCollection.(
      glossary_entries,
      serializer: SerializeLocalizationGlossaryEntries,
      serializer_args: user,
      meta: {
        unscoped_total: Localization::GlossaryEntry.count
      }
    )
  end

  memoize
  def glossary_entries
    Localization::GlossaryEntry::Search.(
      user,
      criteria: params[:criteria],
      status: params[:status],
      page: params[:page],
      locale: params[:filter_locale],
      excluded_ids: params[:excluded_ids]
    )
  end
end
