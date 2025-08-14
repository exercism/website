module LocalizationHelper
  def translate_text(text, markdown: false)
    if I18n.locale == :en
      return (markdown ? Markdown::Parse.(text) : text).html_safe
    end

    translated = Localization::Text::RetrieveTranslation.(text, I18n.locale)
    return unless translated.present?

    (markdown ? Markdown::Parse.(translated) : translated).html_safe

    # TODO: Render waiting widget here...
  end
end
