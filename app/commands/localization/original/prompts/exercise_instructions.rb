class Localization::Original::Prompts::ExerciseInstructions
  include Mandate

  initialize_with :original, :locale

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

      #{context_prompt}

      #{previous_version_prompt}

      ## Text to translate

      These is the English instructions, which YOU SHOULD TRANSLATE:
      ~~~~~~
      #{original.value}
      ~~~~~~

      Respond with JSON containing one field:
      - `value`: The translated text.
    PROMPT
  end

  private
  def context_prompt
    if original.type == :problem_specifications_instructions
      <<~PROMPT
        ## Context

        You are translating the generic (language-agnostic) instructions to an Exercism exercise.
        The slug of the exercise is #{original.object_id}.
      PROMPT
    elsif original.object_type == :exercise_instructions
      exercise = Exercise.find(original.object_id)

      <<~PROMPT
        ## Context

        You are translating the instructions to an Exercism exercise.
        The title of the exercise is #{exercise.title}.
        It is on the #{exercise.track.title} track.

        For your context (DO NOT TRANSLATE THIS), here is some introductory text the user has also seen for this exercise:
        ~~~~~~
        #{exercise.introduction}
        ~~~~~~
      PROMPT
    end
  end

  memoize
  def previous_version_prompt
    return nil unless previous_english_version.present?

    <<~PROMPT
      ## Previous Version

      There was a previous version of these instructions that was translated into this `#{locale}` version and checked/improved by humans.#{' '}
      These instructions have now been updated, but it is essential to honour the previous translation to avoid regressions (where humans have fixed/improved LLM versions).
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
        object_id: object_id
      ),
      status: :checked
    ).last
  end
end
