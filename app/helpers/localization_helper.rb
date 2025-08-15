module LocalizationHelper
  def translate_exercise_introduction(exercise, introduction, markdown: false)
    translated = Localization::Content::TranslateExerciseIntroduction.(exercise, introduction, locale: I18n.locale)
    return unless translated

    (markdown ? Markdown::Parse.(translated) : translated).html_safe

    # TODO: Render waiting widget here...
  end

  def translate_exercise_instructions(exercise, instructions, markdown: false)
    translated = Localization::Content::TranslateExerciseInstructions.(exercise, instructions, locale: I18n.locale)
    return unless translated

    (markdown ? Markdown::Parse.(translated) : translated).html_safe

    # TODO: Render waiting widget here...
  end

  def translate_text(text, markdown: false)
    if I18n.locale == :en
      return (markdown ? Markdown::Parse.(text) : text).html_safe
    end

    translated = Localization::Text::Translate.(text, I18n.locale)
    return unless translated.present?

    (markdown ? Markdown::Parse.(translated) : translated).html_safe

    # TODO: Render waiting widget here...
  end
end
