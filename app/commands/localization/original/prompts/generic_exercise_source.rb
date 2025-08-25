class Localization::Original::Prompts::GenericExerciseSource
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      You are translating a string describing the source of the #{exercise.title} exercise.
      This is the short string that is used to explain where the exercise originated from.
    PROMPT
  end

  def exercise = Exercise.find(original.about_id)
end
