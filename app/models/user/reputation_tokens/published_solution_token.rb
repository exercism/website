class User::ReputationTokens::PublishedSolutionToken < User::ReputationToken
  params :solution
  category :publishing
  reason :published_solution
  levels %i[easy medium hard]
  values({ easy: 1, medium: 2, hard: 3 })

  def guard_params
    "Solution##{solution.id}"
  end

  def i18n_params
    {
      exercise_title: solution.exercise.title,
      track_title: solution.track.title
    }
  end

  def internal_url
    Exercism::Routes.published_solution_url(solution)
  end
end
