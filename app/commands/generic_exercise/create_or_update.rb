class GenericExercise::CreateOrUpdate
  include Mandate

  initialize_with :repo_exercise

  def call
    create!.tap do |exercise|
      exercise.update!(attributes)

      localize!(:generic_exercise_instructions, exercise.instructions, exercise.id)
      localize!(:generic_exercise_introduction, exercise.introduction, exercise.id)
      localize!(:generic_exercise_title, exercise.title, exercise.id)
      localize!(:generic_exercise_blurb, exercise.blurb, exercise.id)
      localize!(:generic_exercise_source, exercise.source, exercise.id)
    end
  end

  private
  def create!
    GenericExercise.find_create_or_find_by!(slug: repo_exercise[:slug]) do |exercise|
      exercise.attributes = attributes
    end
  end

  def localize!(type, content, exercise_id)
    return unless content.present?

    Localization::Text::AddToLocalization.defer(type, content, exercise_id)
  end

  memoize
  def attributes
    {
      slug: repo_exercise[:slug],
      title: repo_exercise[:title],
      blurb: repo_exercise[:blurb],
      source: repo_exercise[:source],
      source_url: repo_exercise[:source_url],
      deep_dive_youtube_id: repo_exercise[:deep_dive_youtube_id],
      deep_dive_blurb: repo_exercise[:deep_dive_blurb],
      status: repo_exercise[:deprecated] ? :deprecated : :active
    }
  end
end
