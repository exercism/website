module HasTranslatedMetadata
  extend ActiveSupport::Concern

  def translated_metadata(unit_id, english)
    return english if I18n.locale == I18n.default_locale
    return english if english.blank?

    repo_name = translation_metadata_repo_name
    translated = TranslationRepo.metadata_text(I18n.locale, repo_name, unit_id)
    return translated if translated

    TranslationRepo.report_missing_metadata!(I18n.locale, repo_name, unit_id)
    ""
  end
end
