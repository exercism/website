class Localization::Original::Prompts::General
  include Mandate

  initialize_with :original, :locale

  def call
    <<~PROMPT
      You are a localization expert. Your task is to translate text from english to a given locale.

      Respond with JSON containing one field:
      - `value`: The translated text

      Follow these rules carefully:
      - Maintain the meaning of the original text. Do not improve or change the meaning.
      - Maintain the tone of the original text, while adhering to the conventions of the target locale.
      - Do not change the length of the text significantly. It should be roughly the same length as the original.
      - If there are placeholders in the text, you should use exact same ones. Do NOT change them.

      The target locale is `#{locale}`

      The original English text was:
      ~~~~~~
      #{original.value}
      ~~~~~~

      This is information about how it's used:
      ~~~~~~
      #{original.usage_details}
      ~~~~~~

      Respond with JSON.
    PROMPT
  end
end
