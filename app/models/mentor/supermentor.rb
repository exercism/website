module Mentor::Supermentor
  ROLE = :supermentor
  MIN_FINISHED_MENTORING_SESSIONS_FOR_TRACK = 100
  MIN_FINISHED_MENTORING_SESSIONS = 100
  MIN_SATISFACTION_PERCENTAGE = 95

  def self.eligible?(mentor)
    mentor.mentor? &&
      mentor.mentor_satisfaction_percentage.to_i >= MIN_SATISFACTION_PERCENTAGE &&
      mentor.track_mentorships.sum(:num_finished_discussions) >= MIN_FINISHED_MENTORING_SESSIONS
  end

  def self.for_track?(mentor, track)
    return true if mentor.staff? || mentor.admin?

    mentor.mentor? &&
      mentor.mentor_satisfaction_percentage.to_i >= MIN_SATISFACTION_PERCENTAGE &&
      mentor.track_mentorships.supermentor_frequency.where(track:).exists?
  end
end
