class SiteUpdates::NewExerciseUpdate < SiteUpdate
  def guard_params = "Exercise##{exercise_id}"

  def i18n_params
    {
      exercise_title: exercise.title,
      exercise_url: Exercism::Routes.track_exercise_url(track, exercise),
      maker_handles:
    }
  end

  def cacheable_rendering_data
    super.merge(
      makers: makers.map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }
      end
    )
  end

  def icon
    {
      type: :image,
      url: exercise.icon_url
    }
  end

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
