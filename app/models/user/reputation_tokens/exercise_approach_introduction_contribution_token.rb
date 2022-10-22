class User::ReputationTokens::ExerciseApproachIntroductionContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_exercise_approach_introduction
  value 5 # TODO: determine value

  before_validation on: :create do
    self.track = contributorship.exercise.track unless track
    self.exercise = contributorship.exercise unless exercise
    self.earned_on = contributorship.created_at unless earned_on
  end

  def i18n_params = { exercise_title: exercise.title }
  def guard_params = "Exercise##{exercise.id}"
  def internal_url = Exercism::Routes.track_exercise_approaches_path(track, exercise)
end
