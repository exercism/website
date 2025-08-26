class Localization::Original::Prompts::ExerciseIntroduction
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      You are translating the introduction to an Exercism exercise.
      The title of the exercise is #{exercise.title}.
      It is on the #{exercise.track.title} track.

      For your context (DO NOT TRANSLATE THIS), here are some instructions that comes straight after this:
      ~~~~~~
      #{exercise.instructions}
      ~~~~~~
    PROMPT
  end

  memoize
  def exercise = original.about
end
