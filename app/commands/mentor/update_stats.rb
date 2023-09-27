class Mentor::UpdateStats
  include Mandate

  queue_as :default

  initialize_with :mentor, :track

  # This command:
  # - Gets the old values
  # - Sets the new values
  # - Triggers some extra checks if they've changed
  def call
    # Firstly we want to update the number of finished discussions
    # for this track. It's important to do this first as the other
    # methods below us this for quicker calculation
    Mentor::UpdateNumFinishedDiscussions.(mentor, track)

    # Now we do the other essential checks
    User::ResetCache.(mentor, :num_students_mentored)
    User::ResetCache.(mentor, :num_solutions_mentored)
    Mentor::UpdateSatisfactionPercentage.(mentor)

    # These can safely be defered into other jobs
    User::UpdateSupermentorRole.defer(mentor)
    User::UpdateAutomatorRole.defer(mentor, track)
    AwardBadgeJob.perform_later(mentor, :mentor)
  end
end
