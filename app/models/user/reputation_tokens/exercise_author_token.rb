class User::ReputationTokens::ExerciseAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_exercise
  value 10

  before_validation on: :create do
    self.track = authorship.exercise.track unless track
    self.exercise = authorship.exercise unless exercise
  end

  def i18n_params
    {
      exercise_title: exercise.title
    }
  end

  def guard_params
    "Exercise##{exercise.id}"
  end
end
