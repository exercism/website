class User::ReputationTokens::AutomationFeedbackAuthorToken < User::ReputationToken
  params :representation
  category :mentoring
  reason :authored_automation_feedback
  value 3

  before_validation on: :create do
    self.track = representation.track unless track
    self.earned_on = representation.updated_at unless earned_on
  end

  def i18n_params =  { exercise_title: representation.exercise.title }
  def guard_params = "Representation##{representation.id}"
  def internal_url = Exercism::Routes.edit_mentoring_automation_path(representation.uuid)
end
