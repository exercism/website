class Localization::Content::TranslateExerciseIntroduction
  include Mandate

  initialize_with :exercise, :introduction, locale: nil

  def call
    # Exit early if someone is actively requesting the English
    # version so that we don't go through extra lookups etc.
    return introduction if locale == :en

    # Look this up here, so we don't do the work of creating the context etc.
    existing = Localization::Translation.find_by(key: key, locale: locale)&.value.presence
    return existing if existing

    # If we don't have it, then translate it. We should rarely get here.
    Localization::Text::Translate.(type, introduction, { exercise_id: exercise.id }, locale)
  end

  private
  def type = :exercise_introduction
  def key = Localization::Text::GenerateKey.(type, introduction)
end
