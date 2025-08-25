module LocalizationHelper
  def translate_exercise_introduction(exercise, markdown: false, solution: nil)
    # We're not syncing old exercise versions, so if someone
    # has an old version, encourage them to upgrade instead
    return translation_or_out_of_date_guard(solution.introduction, markdown:) if solution&.out_of_date?

    translation = Localization::Content::TranslateExerciseIntroduction.(exercise, locale: I18n.locale)

    maybe_parse_as_markdown(translation, markdown) if translation

    # TODO: Render waiting widget here...
  end

  def translate_exercise_instructions(exercise, markdown: false, solution: nil)
    # We're not syncing old exercise versions, so if someone
    # has an old version, encourage them to upgrade instead
    return translation_or_out_of_date_guard(solution.instructions, markdown:) if solution&.out_of_date?

    translation = Localization::Content::TranslateExerciseInstructions.(exercise, locale: I18n.locale)
    maybe_parse_as_markdown(translation, markdown) if translation

    # TODO: Render waiting widget here...
  end

  def translate_text(text, markdown: false)
    return maybe_parse_as_markdown(text, markdown) if I18n.locale == :en

    translation = Localization::Text::Translate.(text, I18n.locale)
    return unless translation.present?

    maybe_parse_as_markdown(translation, markdown)

    # TODO: Render waiting widget here...
  end

  private
  def maybe_parse_as_markdown(text, markdown)
    (markdown ? Markdown::Parse.(text) : text).html_safe
  end

  def translation_or_out_of_date_guard(text, markdown: false)
    translation = Localization::Text::Retrieve.(text, I18n.locale)

    return maybe_parse_as_markdown(translation, markdown) if translation

    # TODO: Render instructions to update + the english version
    maybe_parse_as_markdown(text, markdown)
  end
end
