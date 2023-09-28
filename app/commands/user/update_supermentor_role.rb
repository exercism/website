class User::UpdateSupermentorRole
  include Mandate

  initialize_with :user

  def call
    if eligible?
      User::AddRoles.(user, [:supermentor])
      AwardBadgeJob.perform_later(user, :supermentor)
    else
      User::RemoveRoles.(user, [:supermentor])
    end
  end

  def eligible?
    return false unless user.mentor?
    return false if user.mentor_satisfaction_percentage.to_i < MIN_SATISFACTION_PERCENTAGE
    return false if user.track_mentorships.sum(:num_finished_discussions) < MIN_FINISHED_MENTORING_SESSIONS

    true
  end

  MIN_FINISHED_MENTORING_SESSIONS = 100
  MIN_SATISFACTION_PERCENTAGE = 95
  ROLE = :supermentor
end
