module Mentor::Supermentor
  ROLE = :supermentor
  MIN_FINISHED_MENTORING_SESSIONS = 100
  MIN_SATISFACTION_PERCENTAGE = 95

  def self.eligible?(mentor)
    mentor.mentor? &&
      mentor.mentor_satisfaction_percentage.to_i >= MIN_SATISFACTION_PERCENTAGE &&
      mentor.mentor_discussions.finished.count >= MIN_FINISHED_MENTORING_SESSIONS
  end
end
