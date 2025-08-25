class Localization::Original::Prompts::GenericExerciseTitle
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      You are translating the title of an exercise.
    PROMPT
  end
end
