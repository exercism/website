class User::ReputationTokens::PublishedSolutionToken < User::ReputationToken
  params :solution
  category :publishing
  reason :published_solution
  levels %i[easy medium hard]
  values({ concept: 1, easy: 1, medium: 2, hard: 3 })

  before_validation on: :create do
    self.track = solution.track unless track
    self.exercise = solution.exercise unless exercise
    self.earned_on = solution.published_at unless earned_on
  end

  def guard_params = "Solution##{solution.id}"

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
