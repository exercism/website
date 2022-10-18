class User::ReputationTokens::ExerciseApproachContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_exercise_approach
  value 5 # TODO: determine value

  before_validation on: :create do
    self.approach = contributorship.approach unless approach
    self.exercise = approach.exercise unless exercise
    self.track = exercise.track unless track
    self.earned_on = approach.created_at unless earned_on
  end

  def i18n_params = { approach_title: approach.title, exercise_title: exercise.title }
  def guard_params = "Approach##{exercise.id}"
  def internal_url = Exercism::Routes.track_exercise_approach_path(track, exercise, approach)
end
