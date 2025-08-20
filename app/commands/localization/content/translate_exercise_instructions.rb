class Localization::Content::TranslateExerciseInstructions
  include Mandate

  initialize_with :exercise, locale: nil

  def call
    # Exit early if someone is actively requesting the English
    # version so that we don't go through extra lookups etc.
    return instructions if locale == :en

    # Look this up here, so we don't do the work of creating the context etc.
    existing = Localization::Translation.find_by(key: key, locale: locale)&.value.presence
    return existing if existing

    # If we don't have it, then translate it. We should rarely get here.
    Localization::Text::Translate.(type, instructions, { exercise_id: exercise.id }, locale)
  end

  private
  delegate :instructions, to: :exercise
  def type = :exercise_instructions
  def key = Localization::Text::GenerateKey.(instructions)
end
