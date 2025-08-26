class Localization::Original::Prompts::ExerciseInstructions
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
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

  memoize
  def exercise = original.about
end
