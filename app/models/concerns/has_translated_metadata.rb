module HasTranslatedMetadata
  extend ActiveSupport::Concern

  # A unit with no translation falls back to its English. The miss is reported
  # only when a translation is expected (see translation_expected?), which
  # matches what exercism/i18n requires to be translated.
  def translated_metadata(unit_id, english)
    return english if I18n.locale == I18n.default_locale
    return english if english.blank?

    repo_name = translation_metadata_repo_name
    return english unless repo_name

    translated = TranslationRepo.metadata_text(I18n.locale, repo_name, unit_id)
    return translated if translated

    TranslationRepo.report_missing_metadata!(I18n.locale, repo_name, unit_id) if translation_expected?
    english
  end

  # Whether this record's metadata is meant to be translated. A model whose
  # records can be inactive, work in progress or deprecated overrides this,
  # because exercism/i18n does not require those.
  def translation_expected? = true
end
