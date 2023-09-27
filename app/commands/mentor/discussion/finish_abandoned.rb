class Mentor::Discussion::FinishAbandoned
  include Mandate

  def call
    discussions_to_abandon.each do |discussion|
      finish!(discussion)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  private
  def discussions_to_abandon
    Mentor::Discussion.
      where(status: %i[mentor_finished student_timed_out]).
      where('finished_at <= ?', Time.current.utc - 1.week)
  end

  def finish!(discussion)
    discussion.update!(
      status: :finished,
      awaiting_mentor_since: nil,
      awaiting_student_since: nil
    )
    Mentor::Discussion::ProcessFinished.(discussion)
  end
end
