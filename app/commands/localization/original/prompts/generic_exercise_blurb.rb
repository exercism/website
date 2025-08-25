class Localization::Original::Prompts::GenericExerciseBlurb
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      You are translating the blurb of the #{exercise.title} exercise.
      This is the short string that is used to describe the exercise around the site.
    PROMPT
  end

  def exercise = Exercise.find(original.about_id)
end
