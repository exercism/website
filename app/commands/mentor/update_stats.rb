class Mentor::UpdateStats
  include Mandate

  queue_as :default

  initialize_with :mentor, :track

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

    new_values[0] = User::ResetCache.(mentor, :num_students_mentored)
    new_values[1] = User::ResetCache.(mentor, :num_solutions_mentored)
    new_values[2] = Mentor::UpdateSatisfactionPercentage.(mentor)

    # This should happen in band at the same time as the above code
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)

    return unless old_values != new_values

    # These can safely be defered into other jobs
    User::UpdateSupermentorRole.defer(mentor)
    User::UpdateAutomatorRole.defer(mentor, track)
    AwardBadgeJob.perform_later(mentor, :mentor)
  end
end
