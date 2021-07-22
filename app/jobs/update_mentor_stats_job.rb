class UpdateMentorStatsJob < ApplicationJob
  queue_as :default

  def perform(mentor, update_num_solutions: false, update_satisfaction_rating: false)
    Mentor::UpdateNumSolutionsMentored.(mentor) if update_num_solutions
    Mentor::UpdateSatisfactionRating.(mentor) if update_satisfaction_rating
  end
end
