class User::ReputationTokens::ExerciseApproachAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_exercise_approach
  value 12 # TODO: determine value

  before_validation on: :create do
    self.approach = authorship.approach unless approach
    self.exercise = approach.exercise unless exercise
    self.track = exercise.track unless track
    self.earned_on = approach.created_at unless earned_on
  end

  def i18n_params = { approach_title: approach.title, exercise_title: exercise.title }
  def guard_params = "Approach##{approach.id}"
  def internal_url = Exercism::Routes.track_exercise_approach_path(track, exercise, approach)
end
