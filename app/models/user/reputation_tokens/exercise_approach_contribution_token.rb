class User::ReputationTokens::ExerciseApproachContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_exercise_approach
  value 5 # TODO: determine value

  before_validation on: :create do
    self.exercise = contributorship.approach.exercise unless exercise
    self.track = contributorship.approach.track unless track
    self.earned_on = contributorship.created_at unless earned_on
  end

  def i18n_params = { approach_title: contributorship.approach.title, exercise_title: exercise.title }
  def guard_params = "Approach##{contributorship.approach.id}"
  def internal_url = Exercism::Routes.track_exercise_approach_path(track, exercise, contributorship.approach)
end
