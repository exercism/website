class Localization::Original::Prompts::ExerciseSource
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericExerciseSource.(original, locale)
  end
end
