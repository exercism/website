class Mentor::Discussion::UpdateTimedOut
  include Mandate

  def call
    update_student_timed_out!
    update_mentor_timed_out!
  end

  private
  def update_student_timed_out!
    student_timed_out_discussions.find_each do |discussion|
      Mentor::Discussion::StudentTimedOut.(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def student_timed_out_discussions
    Mentor::Discussion.includes(:student).
      awaiting_student.
      where('awaiting_student_since < ?', timeout_date)
  end

  def update_mentor_timed_out!
    mentor_timed_out_discussions.find_each do |discussion|
      Mentor::Discussion::MentorTimedOut.(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def mentor_timed_out_discussions
    Mentor::Discussion.includes(:mentor).
      awaiting_mentor.
      where('awaiting_mentor_since < ?', timeout_date)
  end

  def timeout_date = Time.now.utc - Mentor::Discussion::DAYS_BEFORE_TIME_OUT
end
