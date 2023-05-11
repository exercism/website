class Mentor::UpdateStats
  include Mandate

  queue_as :default

  initialize_with :mentor, update_num_solutions_mentored: false, update_satisfaction_rating: false

  def call
    old_values = [
      mentor.num_solutions_mentored,
      mentor.mentor_satisfaction_percentage
    ]

    Mentor::UpdateNumSolutionsMentored.(mentor) if update_num_solutions_mentored
    Mentor::UpdateSatisfactionPercentage.(mentor) if update_satisfaction_rating

    new_values = [
      mentor.num_solutions_mentored,
      mentor.mentor_satisfaction_percentage
    ]

    User::UpdateMentorRoles.defer(mentor) if old_values != new_values
  end
end
