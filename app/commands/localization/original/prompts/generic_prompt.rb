class Localization::Original::Prompts::GenericPrompt
  include Mandate

  initialize_with :original, :locale, :context

  def call
    <<~PROMPT
      ## Instructions

      You are a localization expert. Your task is to translate text from english to a given locale.

      Follow these rules carefully:
      - Maintain the meaning of the original text. Do not improve or change the meaning.
      - Maintain the tone of the original text, while adhering to the conventions of the target locale.
      - Do not change the length of the text significantly. It should be roughly the same length as the original.

      When dealing with codeblocks:
      - Do NOT change ANY code (including variable names).
      - You CAN translate comments from english to `#{locale}` while refering to the correct variables etc if appropriate.

      The target locale is `#{locale}`

      #{context}

      #{previous_version_prompt}

      ## Text to translate

      These is the English value, which YOU SHOULD TRANSLATE:
      ~~~~~~
      #{original.value}
      ~~~~~~

      Respond with JSON containing one field:
      - `value`: The translated text.
    PROMPT
  end

  private
  memoize
  def previous_version_prompt
    return nil unless previous_english_version.present?

    <<~PROMPT
      ## Previous Version

      There was a previous version of this text that was translated into this `#{locale}` version and checked/improved by humans.#{' '}
      This text has now been updated, but it is essential to honour the previous translation to avoid regressions (where humans have fixed/improved LLM versions).
      So you should reuse existing translations where possible and only add your own translations to the areas that have changed in the English.

      This was the previous English version:
      ~~~~~~
      #{previous_english_version}
      ~~~~~~

      This was the previous `#{locale}` version:
      ~~~~~~
      #{previous_translated_version}
      ~~~~~~

      In the next section where you see the text to translate, you should reuse information from this previous translation where possible.
    PROMPT
  end

  memoize
  def previous_english_version
    return unless previous_translated_version

    previous_translated_version.original.translations.find_by(locale: :en)
  end

  memoize
  def previous_translated_version
    Localization::Translation.where(
      locale: locale,
      original: Localization::Original.where(
        type: original.type,
        about_type: original.about_type,
        about_id: original.about_id
      ),
      status: :checked
    ).last
  end
end
