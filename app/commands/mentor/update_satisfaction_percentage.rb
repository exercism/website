class Mentor::UpdateSatisfactionPercentage
  include Mandate

  initialize_with :mentor

  def call
    User::ResetCache.(mentor, :mentor_satisfaction_percentage)
  end
end
