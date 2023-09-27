class User::UpdateAutomatorRole
  include Mandate

  initialize_with :user, :track

  def call
    # Don't undo this if not elligible as some people are manually added
    mentorship.update!(automator: true) if eligible?
  end

  def eligible?
    return false unless user.mentor?
    return false unless mentorship
    return false if user.mentor_satisfaction_percentage.to_i < MIN_SATISFACTION_PERCENTAGE
    return false if mentorship.num_finished_discussions < MIN_FINISHED_MENTORING_SESSIONS

    true
  end

  def mentorship
    user.track_mentorships.find_by(track:)
  end

  MIN_SATISFACTION_PERCENTAGE = 95
  MIN_FINISHED_MENTORING_SESSIONS = 100
end
