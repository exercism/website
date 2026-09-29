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
    return I18n.t("site_updates.maker_handles.we") if makers.empty?
    return makers[0, 3].map(&:handle).to_sentence if makers.size <= 3

    I18n.t(
      "site_updates.maker_handles.with_others",
      first: makers[0].handle,
      second: makers[1].handle,
      count: makers.size - 2
    )
  end

  memoize
  def makers
    exercise.authors + exercise.contributors
  end
end
