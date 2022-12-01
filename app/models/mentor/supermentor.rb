module Mentor::Supermentor
  ROLE = :supermentor
  MIN_NUM_SOLUTIONS_MENTORED_PER_TRACK = 100
  MIN_FINISHED_MENTORING_SESSIONS = 100
  MIN_SATISFACTION_PERCENTAGE = 95

  def self.eligible?(mentor)
    mentor.mentor? &&
      mentor.mentor_satisfaction_percentage.to_i >= MIN_SATISFACTION_PERCENTAGE &&
      mentor.mentor_discussions.finished.count >= MIN_FINISHED_MENTORING_SESSIONS
  end

  def self.for_track?(mentor, track)
    return true if mentor.staff? || mentor.admin?

    mentor.mentor_discussions.
      joins(:request).
      finished_for_student.
      where(request: { track: }).
      count >= MIN_NUM_SOLUTIONS_MENTORED_PER_TRACK
  end
end
