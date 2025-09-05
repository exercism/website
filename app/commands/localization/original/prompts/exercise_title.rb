class Localization::Original::Prompts::ExerciseTitle
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericExerciseTitle.(original, locale)
  end
end
