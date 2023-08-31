class Mentor::Discussion::UpdateTimedOut
  include Mandate

  def call
    update_student_timed_out!
    update_mentor_timed_out!
  end

  private
  def update_student_timed_out!
    student_timed_out_discussions.find_each do |discussion|
      student_timed_out!(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def student_timed_out_discussions
    Mentor::Discussion.includes(:student).
      awaiting_student.
      where('awaiting_student_since < ?', timeout_date)
  end

  def student_timed_out!(discussion)
    num_days_waiting = NUM_DAYS_WAITING_CUTOFFS.find do |cutoff|
      Time.now.utc.to_date - discussion.awaiting_student_since.utc.to_date >= cutoff
    end

    User::Notification::Create.(
      discussion.student,
      :discussion_timed_out_for_student,
      discussion:,
      num_days_waiting:
    )
  end

  def update_mentor_timed_out!
    mentor_timed_out_discussions.find_each do |discussion|
      mentor_timed_out!(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def mentor_timed_out_discussions
    Mentor::Discussion.includes(:mentor).
      awaiting_mentor.
      where('awaiting_mentor_since < ?', timeout_date)
  end

  def mentor_timed_out!(discussion)
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

  def timeout_date = Time.now.utc - 28.days
end
