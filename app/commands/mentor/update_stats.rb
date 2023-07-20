class Mentor::UpdateStats
  include Mandate

  queue_as :default

  initialize_with :mentor,
    update_counts: false,
    update_satisfaction_rating: false

  # This command:
  # - Gets the old values
  # - Sets the new values
  # - Triggers some extra checks if they've changed
  def call
    # Actively use the cache to get these values as we don't want
    # to follow the automatic setting pathway we normally use.
    old_values = [
      mentor.data.cache['num_students_mentored'],
      mentor.data.cache['num_solutions_mentored'],
      mentor.data.cache['mentor_satisfaction_percentage']
    ]
    new_values = old_values.clone

    new_values[0] = User::ResetCache.(mentor, :num_students_mentored) if update_counts
    new_values[1] = User::ResetCache.(mentor, :num_solutions_mentored) if update_counts
    new_values[2] = Mentor::UpdateSatisfactionPercentage.(mentor) if update_satisfaction_rating

    User::UpdateMentorRoles.defer(mentor) if old_values != new_values
  end
end
