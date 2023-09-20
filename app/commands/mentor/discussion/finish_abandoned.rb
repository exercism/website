class Mentor::Discussion::FinishAbandoned
  include Mandate

  def call
    Mentor::Discussion.
      where(status: %i[mentor_finished student_timed_out]).
      where('finished_at <= ?', Time.current.utc - 1.week).
      each do |discussion|
      discussion.update!(
        status: :finished,
        awaiting_mentor_since: nil,
        awaiting_student_since: nil
      )
    end
  end
end
