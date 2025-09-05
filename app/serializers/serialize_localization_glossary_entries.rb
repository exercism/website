class SerializeLocalizationGlossaryEntries
  include Mandate

  initialize_with :glossary_entries, :user

  def call
    glossary_entries_with_includes.map do |glossary_entry|
      {
        uuid: glossary_entry.uuid,
        locale: glossary_entry.locale,
        term: glossary_entry.term,
        translation: glossary_entry.translation,
        status: glossary_entry.status.to_s,
        llm_instructions: glossary_entry.llm_instructions,
        proposals_count: proposals[glossary_entry.id]&.length || 0
      }
    end
  end

  def glossary_entries_with_includes
    glossary_entries.to_active_relation
  end

  memoize
  def proposals
    Localization::GlossaryEntryProposal.
      where(glossary_entry: glossary_entries).
      where.not(status: :rejected).
      group_by(&:glossary_entry_id)
  end
end
