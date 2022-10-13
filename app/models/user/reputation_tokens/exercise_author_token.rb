class User::ReputationTokens::ExerciseAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_exercise
  value 20

  before_validation on: :create do
    self.track = authorship.exercise.track unless track
    self.exercise = authorship.exercise unless exercise
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
