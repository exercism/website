class Localization::Original::Prompts::ExerciseDescription
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      You are translating the introduction/instructions for an Exercism exercise.
      The title of the exercise is #{exercise.title}.
      It is on the #{exercise.track.title} track.
    PROMPT
  end

  def exercise = Exercise.find(original.about_id)
end
