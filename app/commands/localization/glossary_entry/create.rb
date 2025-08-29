class Localization::GlossaryEntry::Create
  include Mandate

  initialize_with :locale, :term, :translation, :llm_instructions

  def call
    Localization::GlossaryEntry.create!(
      locale:,
      term:,
      translation:,
      llm_instructions:
    )
  end
end
