class Localization::Original::Prompts::ExerciseInstructions
  include Mandate

  initialize_with :original, :locale

  def call
    <<~PROMPT
      You are a localization expert. Your task is to translate text from english to a given locale.

      You are translating the instructions to an Exercism exercise.
      The title of the exercise is #{exercise.title}.
      It is on the #{exercise.track.title} track.

      Respond with JSON containing one field:
      - `value`: The translated text

      Follow these rules carefully:
      - Maintain the meaning of the original text. Do not improve or change the meaning.
      - Maintain the tone of the original text, while adhering to the conventions of the target locale.
      - Do not change the length of the text significantly. It should be roughly the same length as the original.

      When dealing with codeblocks:
      - Do NOT change ANY code (including variable names).#{' '}
      - You CAN translate comments from english to `#{locale}` while refering to the correct variables etc if appropriate.

      The target locale is `#{locale}`

      For your context (DO NOT TRANSLATE THIS), here is some introductory text the user has also seen for this exercise:
      ~~~~~~
      #{exercise.introduction}
      ~~~~~~

      The original English instructions, which you should translate, is:
      ~~~~~~
      #{original.value}
      ~~~~~~

      Respond with JSON.
    PROMPT
  end

  memoize
  def exercise = Exercise.find(original.data[:exercise_id])
end
