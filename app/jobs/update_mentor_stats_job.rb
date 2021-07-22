class UpdateMentorStatsJob < ApplicationJob
  queue_as :default

  def perform(mentor, update_num_solutions:, update_satisfaction_percentage:)
    Mentor::UpdateNumSolutionsMentored.(mentor) if update_num_solutions
    Mentor::UpdateSatisfactionRating.(mentor) if update_satisfaction_percentage
  end
end
