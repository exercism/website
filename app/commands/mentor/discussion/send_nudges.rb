class Mentor::Discussion::SendNudges
  include Mandate

  def call
    nudge_students!
    nudge_mentors!
  end

  private
  def nudge_students!
    student_nudge_discussions.find_each do |discussion|
      num_days_waiting = num_days_waiting_since(discussion.awaiting_student_since)
      Mentor::Discussion::NudgeStudent.(discussion, num_days_waiting)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def student_nudge_discussions
    Mentor::Discussion.includes(:student).
      awaiting_student.
      where('awaiting_student_since < ?', Time.now.utc - 7.days)
  end

  def nudge_mentors!
    mentor_nudge_discussions.find_each do |discussion|
      num_days_waiting = num_days_waiting_since(discussion.awaiting_mentor_since)
      Mentor::Discussion::NudgeMentor.(discussion, num_days_waiting)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def mentor_nudge_discussions
    Mentor::Discussion.includes(:mentor).
      awaiting_mentor.
      where('awaiting_mentor_since < ?', Time.now.utc - 7.days)
  end

  def num_days_waiting_since(time)
    NUM_DAYS_WAITING_CUTOFFS.find do |cutoff|
      Time.now.utc.to_date - time.utc.to_date >= cutoff
    end
  end

  NUM_DAYS_WAITING_CUTOFFS = [21, 14, 7].freeze
  private_constant :NUM_DAYS_WAITING_CUTOFFS
end
