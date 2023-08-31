class Mentor::Discussion::SendNudges
  include Mandate

  def call
    nudge_students!
    nudge_mentors!
  end

  private
  def nudge_students!
    student_nudge_discussions.find_each do |discussion|
      nudge_student!(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def student_nudge_discussions
    Mentor::Discussion.includes(:student).
      awaiting_student.
      where('awaiting_student_since < ?', Time.now.utc - 7.days)
  end

  def nudge_student!(discussion)
    num_days_waiting = NUM_DAYS_WAITING_CUTOFFS.find do |cutoff|
      Time.now.utc.to_date - discussion.awaiting_student_since.utc.to_date >= cutoff
    end

    User::Notification::Create.(
      discussion.student,
      :nudge_student_to_reply_in_discussion,
      discussion:,
      num_days_waiting:
    )
  end

  def nudge_mentors!
    mentor_nudge_discussions.find_each do |discussion|
      nudge_mentor!(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def mentor_nudge_discussions
    Mentor::Discussion.includes(:mentor).
      awaiting_mentor.
      where('awaiting_mentor_since < ?', Time.now.utc - 7.days)
  end

  def nudge_mentor!(discussion)
    num_days_waiting = NUM_DAYS_WAITING_CUTOFFS.find do |cutoff|
      Time.now.utc.to_date - discussion.awaiting_mentor_since.utc.to_date >= cutoff
    end

    User::Notification::Create.(
      discussion.mentor,
      :nudge_mentor_to_reply_in_discussion,
      discussion:,
      num_days_waiting:
    )
  end

  NUM_DAYS_WAITING_CUTOFFS = [21, 14, 7].freeze
  private_constant :NUM_DAYS_WAITING_CUTOFFS
end
