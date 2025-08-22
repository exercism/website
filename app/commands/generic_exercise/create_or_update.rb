class GenericExercise::CreateOrUpdate
  include Mandate

  initialize_with :repo_exercise

  def call
    create!.tap do |exercise|
      exercise.update!(attributes)

      if repo_exercise.description.present?
        Localization::Text::AddToLocalization.defer(:generic_exercise_description, repo_exercise.description,
          exercise.id)
      end
      if repo_exercise.instructions.present?
        Localization::Text::AddToLocalization.(:generic_exercise_instructions, repo_exercise.instructions, exercise.id,
          priority_locale: :hu)
      end
      if repo_exercise.introduction.present?
        Localization::Text::AddToLocalization.(:generic_exercise_introduction, repo_exercise.introduction,
          exercise.id)
      end

      Localization::Text::AddToLocalization.defer(:generic_exercise_title, repo_exercise.title, exercise.id)
      Localization::Text::AddToLocalization.defer(:generic_exercise_blurb, repo_exercise.blurb, exercise.id)
      if repo_exercise.source.present?
        Localization::Text::AddToLocalization.defer(:generic_exercise_source, repo_exercise.source,
          exercise.id)
      end
    end
  end

  private
  def create!
    GenericExercise.find_create_or_find_by!(slug: repo_exercise.slug) do |exercise|
      exercise.attributes = attributes
    end
  end

  memoize
  def attributes
    {
      slug: repo_exercise.slug,
      title: repo_exercise.title,
      blurb: repo_exercise.blurb,
      source: repo_exercise.source,
      source_url: repo_exercise.source_url,
      deep_dive_youtube_id: repo_exercise.deep_dive_youtube_id,
      deep_dive_blurb: repo_exercise.deep_dive_blurb,
      status: repo_exercise.deprecated? ? :deprecated : :active
    }
  end
end
