class Mentor::Discussion::HandleAbandonedByStudent
  include Mandate

  def call
    Mentor::Discussion.
      where(status: %i[mentor_finished student_timed_out]).
      where('finished_at <= ?', Time.current.utc - 1.week).
      each(&:student_abandoned!)
  end
end
