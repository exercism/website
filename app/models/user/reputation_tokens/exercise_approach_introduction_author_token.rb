class User::ReputationTokens::ExerciseApproachIntroductionAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_exercise_approach_introduction
  value 12 # TODO: determine value

  before_validation on: :create do
    self.track = authorship.exercise.track unless track
    self.exercise = authorship.exercise unless exercise
    self.earned_on = authorship.created_at unless earned_on
  end

  def i18n_params = { exercise_title: exercise.title }
  def guard_params = "Exercise##{exercise.id}"
  def internal_url = Exercism::Routes.track_exercise_approaches_path(track, exercise)
end
