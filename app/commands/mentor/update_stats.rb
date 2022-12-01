class Mentor::UpdateStats < ApplicationJob
  queue_as :default

  def perform(mentor, update_num_solutions_mentored: false, update_satisfaction_rating: false)
    Mentor::UpdateNumSolutionsMentored.(mentor) if update_num_solutions_mentored
    Mentor::UpdateSatisfactionRating.(mentor) if update_satisfaction_rating
  end
end
