class SiteUpdates::NewExerciseUpdate < SiteUpdate
  params :author, :title, :description, :pull_request

  def guard_params
    "Exercise##{exercise_id}"
  end

  def i18n_params
    {
      exercise_title: exercise.title,
      exercise_url: Exercism::Routes.track_exercise_url(track, exercise),
      maker_handles: maker_handles
    }
  end

  def cacheable_rendering_data
    super.merge(
      maker_avatar_urls: makers.map(&:avatar_url)
    )
  end

  delegate :icon_url, to: :exercise

  def maker_handles
    return "We" if makers.empty?
    return makers[0, 3].map(&:handle).to_sentence if makers.size <= 3

    "#{makers[0].handle}, #{makers[1].handle}, and #{makers.size - 2} others"
  end

  memoize
  def makers
    exercise.authors + exercise.contributors
  end
end
