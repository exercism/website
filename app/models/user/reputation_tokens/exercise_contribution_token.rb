class User::ReputationTokens::ExerciseContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_exercise
  value 10

  before_validation on: :create do
    self.track = contributorship.exercise.track unless track
    self.exercise = contributorship.exercise unless exercise
    self.earned_on = exercise.created_at unless earned_on
  end

  def i18n_params
    {
      exercise_title: exercise.title
    }
  end

  def guard_params = "Exercise##{exercise.id}"

  def internal_url
    Exercism::Routes.track_exercise_path(track, exercise)
  end
end
