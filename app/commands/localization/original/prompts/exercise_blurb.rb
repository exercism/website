class Localization::Original::Prompts::ExerciseBlurb
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericExerciseBlurb.(original, locale)
  end
end
