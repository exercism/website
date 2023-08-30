class Mentor::Discussion::SendNudges
  include Mandate

  def call
    nudge_students!
  end

  private
  def nudge_students!
    student_nudge_discussions.find_each do |discussion|
      nudge_student!(discussion)
    end
  end

  def student_nudge_discussions
    Mentor::Discussion.
      includes(:student, :exercise, :track).
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

  NUM_DAYS_WAITING_CUTOFFS = [21, 14, 7].freeze
  private_constant :NUM_DAYS_WAITING_CUTOFFS
end
