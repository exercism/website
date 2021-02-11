class User::ReputationTokens::ExerciseContribution < User::ReputationToken
  before_create do
    self.user = contributorship.contributor
    self.context_key = "contributed_to_exercise/#{contributorship.exercise.uuid}"
    self.reason = :authoring
    self.category = :contributed_to_exercise
    self.context = contributorship
    self.track = contributorship.exercise.track
    self.exercise = contributorship.exercise
  end

  def contributorship
    params[:contributorship]
  end
end
