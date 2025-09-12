class Localization::GlossaryEntry::Create
  include Mandate

  initialize_with :user, :locale, :term, :translation, :llm_instructions

  def call
    guard!

    Localization::GlossaryEntry.create!(
      locale:,
      term:,
      translation:,
      llm_instructions:
    )
  rescue ActiveRecord::RecordNotUnique
    Localization::GlossaryEntry.find_by!(locale:, term:)
  end

  def guard!
    return if user.may_create_translation_proposals?

    raise "You need to have at least 10 rep to create glossary entries"
  end
end
